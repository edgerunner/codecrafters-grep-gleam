import gleam/int
import gleam/iterator.{type Iterator}
import gleam/list
import gleam/result
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
  Backreference(Int)
}

type Scaffold {
  Start
  Escape
  GroupScaffold(characters: List(String), negative: Bool)
  CaptureScaffold(List(Iterator(String)), depth: Int)
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
    Error(Start), "\\" | Ok(_), "\\" -> Error(Escape)
    Error(Escape), "d" -> Ok(Digit)
    Error(Escape), "w" -> Ok(Word)
    Error(Escape), x ->
      int.parse(x)
      |> result.map(Backreference)
      |> result.unwrap(Literal(x))
      |> Ok
    Ok(_), "+" -> Ok(OneOrMore)
    Ok(_), "?" -> Ok(OneOrNone)
    Ok(_), "." -> Ok(Wildcard)
    Ok(_), "$" -> Ok(EndAnchor)
    Error(Start), "^" -> Ok(StartAnchor)
    Error(Start), "(" | Ok(_), "(" ->
      Error(CaptureScaffold([iterator.empty()], 0))
    Error(CaptureScaffold(scaffold, depth)), "(" ->
      append_to(scaffold, "(")
      |> CaptureScaffold(depth + 1)
      |> Error
    Error(CaptureScaffold(scaffold, 0)), "|" ->
      Error(CaptureScaffold([iterator.empty(), ..scaffold], 0))
    Error(CaptureScaffold(scaffold, 0)), ")" ->
      list.reverse(scaffold) |> list.map(lex_graphemes) |> Capture |> Ok
    Error(CaptureScaffold(scaffold, depth)), ")" ->
      append_to(scaffold, ")")
      |> CaptureScaffold(depth - 1)
      |> Error
    Error(CaptureScaffold(scaffold, depth)), c -> {
      append_to(scaffold, c)
      |> CaptureScaffold(depth)
      |> Error
    }
    _, "[" -> Error(GroupScaffold(characters: [], negative: False))
    Error(GroupScaffold([], False)), "^" -> Error(GroupScaffold([], True))
    Error(GroupScaffold(characters, False)), "]" ->
      Ok(PositiveCharacterGroup(characters))
    Error(GroupScaffold(characters, True)), "]" ->
      Ok(NegativeCharacterGroup(characters))
    Error(GroupScaffold(characters, negative)), c ->
      [c, ..characters] |> GroupScaffold(negative) |> Error
    _, _ -> Ok(Literal(grapheme))
  }
}

fn append_to(
  scaffold: List(Iterator(String)),
  grapheme: String,
) -> List(Iterator(String)) {
  let assert [alternative, ..others] = scaffold
  iterator.single(grapheme)
  |> iterator.append(to: alternative, suffix: _)
  |> list.prepend(others, _)
}
