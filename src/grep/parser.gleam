import gleam/iterator
import grep/lexer

pub type Grep {
  /// This is the end of a chain. If you reach this, you have a match
  Match
  /// Match a literal string verbatim
  Literal(String, next: Grep)
  /// Match a decimal digit 0-9
  Digit(next: Grep)
}

pub fn parse(source: String) -> Grep {
  {
    use grep, token <- iterator.fold(over: lexer.lex(source), from: Match)
    case token {
      lexer.Literal(s) -> Literal(s, grep)
      lexer.Digit -> Digit(grep)
    }
  }
  |> reverse(Match)
}

fn reverse(grep: Grep, reversed: Grep) -> Grep {
  case grep {
    Match -> reversed
    Literal(s, next) -> reverse(next, Literal(s, reversed))
    Digit(next) -> reverse(next, Digit(reversed))
  }
}
