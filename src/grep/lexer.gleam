import gleam/iterator.{type Iterator}
import gleam/string

pub type Token {
  Literal(String)
  Digit
  Word
}

pub fn lex(source: String) -> Iterator(Token) {
  unfold(source)
  |> iterator.scan(from: Error(""), with: fn(state, grapheme) {
    case state, grapheme {
      _, "\\" -> Error("\\")
      Error("\\"), "d" -> Ok(Digit)
      Error("\\"), "w" -> Ok(Word)
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
