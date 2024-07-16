import gleam/iterator.{type Iterator}
import gleam/list
import gleam/string

pub type Token {
  Literal(String)
  Digit
  Word
  PositiveCharacterGroup(List(String))
  NegativeCharacterGroup(List(String))
  StartAnchor
  EndAnchor
  OneOrMore
  OneOrNone
  Wildcard
  Capture(List(Iterator(Token)))
}

type Scaffold {
  Start
  Escape
  GroupScaffold(characters: List(String), negative: Bool)
  CaptureScaffold(List(Iterator(String)))
}

pub fn lex(source: String) -> Iterator(Token) {
  unfold(source)
  |> lex_graphemes
}

fn lex_graphemes(graphemes: Iterator(String)) -> Iterator(Token) {
  iterator.scan(over: graphemes, from: Error(Start), with: lex_single_grapheme)
  |> iterator.filter_map(fn(x) { x })
}

fn unfold(source: String) -> Iterator(String) {
  use input <- iterator.unfold(from: source)
  case string.pop_grapheme(input) {
    Ok(#(grapheme, rest)) -> iterator.Next(element: grapheme, accumulator: rest)
    Error(Nil) -> iterator.Done
  }
}

fn lex_single_grapheme(
  state: Result(Token, Scaffold),
  grapheme: String,
) -> Result(Token, Scaffold) {
  case state, grapheme {
    _, "\\" -> Error(Escape)
    Error(Escape), "d" -> Ok(Digit)
    Error(Escape), "w" -> Ok(Word)
    Error(Escape), x -> Ok(Literal(x))
    Ok(_), "+" -> Ok(OneOrMore)
    Ok(_), "?" -> Ok(OneOrNone)
    Ok(_), "." -> Ok(Wildcard)
    _, "$" -> Ok(EndAnchor)
    Error(Start), "^" -> Ok(StartAnchor)
    _, "(" -> Error(CaptureScaffold([iterator.empty()]))
    Error(GroupScaffold([], False)), "^" -> Error(GroupScaffold([], True))
    Error(CaptureScaffold(alternatives)), "|" ->
      Error(CaptureScaffold([iterator.empty(), ..alternatives]))
    Error(CaptureScaffold(alternatives)), ")" ->
      list.reverse(alternatives) |> list.map(lex_graphemes) |> Capture |> Ok
    Error(CaptureScaffold([alternative, ..others])), c -> {
      iterator.single(c)
      |> iterator.append(to: alternative, suffix: _)
      |> list.prepend(others, _)
      |> CaptureScaffold
      |> Error
    }
    _, "[" -> Error(GroupScaffold(characters: [], negative: False))
    Error(GroupScaffold(characters, False)), "]" ->
      Ok(PositiveCharacterGroup(characters))
    Error(GroupScaffold(characters, True)), "]" ->
      Ok(NegativeCharacterGroup(characters))
    Error(GroupScaffold(characters, negative)), c ->
      [c, ..characters] |> GroupScaffold(negative) |> Error
    _, _ -> Ok(Literal(grapheme))
  }
}
