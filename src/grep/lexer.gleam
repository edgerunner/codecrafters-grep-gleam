import gleam/iterator.{type Iterator}
import gleam/string

pub type Token {
  Literal(String)
  Digit
  Word
  Group(Bool)
}

pub fn lex(source: String) -> Iterator(Token) {
  unfold(source)
  |> iterator.scan(from: Error(""), with: fn(state, grapheme) {
    case state, grapheme {
      _, "\\" -> Error("\\")
      Error("\\"), "d" -> Ok(Digit)
      Error("\\"), "w" -> Ok(Word)
      Error("\\"), "[" -> Ok(Literal("["))
      Error("\\"), "]" -> Ok(Literal("]"))
      _, "[" -> Ok(Group(True))
      _, "]" -> Ok(Group(False))
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
