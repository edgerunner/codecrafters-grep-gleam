import gleam/iterator.{type Iterator}
import gleam/set.{type Set}
import gleam/string

pub type Token {
  Literal(String)
  Digit
  Word
  PositiveCharacterGroup(Set(String))
}

type Scaffold {
  Start
  Escape
  GroupScaffold(characters: set.Set(String))
}

pub fn lex(source: String) -> Iterator(Token) {
  unfold(source)
  |> iterator.scan(from: Error(Start), with: fn(state, grapheme) {
    case state, grapheme {
      _, "\\" -> Error(Escape)
      Error(Escape), "d" -> Ok(Digit)
      Error(Escape), "w" -> Ok(Word)
      Error(Escape), "[" -> Ok(Literal("["))
      Error(Escape), "]" -> Ok(Literal("]"))
      _, "[" -> Error(GroupScaffold(characters: set.new()))
      Error(GroupScaffold(characters)), "]" ->
        Ok(PositiveCharacterGroup(characters))
      Error(GroupScaffold(characters)), c ->
        set.insert(characters, c) |> GroupScaffold |> Error
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
