import gleam/iterator.{type Iterator}
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
}

type Scaffold {
  Start
  Escape
  GroupScaffold(characters: List(String), negative: Bool)
}

pub fn lex(source: String) -> Iterator(Token) {
  unfold(source)
  |> iterator.scan(from: Error(Start), with: fn(state, grapheme) {
    case state, grapheme {
      _, "\\" -> Error(Escape)
      Error(Escape), "d" -> Ok(Digit)
      Error(Escape), "w" -> Ok(Word)
      Error(Escape), x -> Ok(Literal(x))
      Ok(_), "+" -> Ok(OneOrMore)
      Ok(_), "?" -> Ok(OneOrNone)
      _, "$" -> Ok(EndAnchor)
      Error(Start), "^" -> Ok(StartAnchor)
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
  })
  |> iterator.filter_map(fn(x) { x })
}

fn unfold(source: String) -> Iterator(String) {
  use input <- iterator.unfold(from: source)
  case string.pop_grapheme(input) {
    Ok(#(grapheme, rest)) -> iterator.Next(element: grapheme, accumulator: rest)
    Error(Nil) -> iterator.Done
  }
}
