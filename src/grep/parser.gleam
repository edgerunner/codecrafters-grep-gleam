import gleam/int
import gleam/iterator
import gleam/list
import grep/lexer

pub type Grep {
  /// This is the end of a chain. If you reach this, you have a match
  Match
  /// Match a literal string verbatim
  Literal(String, next: Grep)
  /// Match any one of the choices
  OneOf(List(Grep), next: Grep)
}

pub fn parse(source: String) -> Grep {
  {
    use grep, token <- iterator.fold(over: lexer.lex(source), from: Match)
    case token {
      lexer.Literal(s) -> Literal(s, grep)
      lexer.Digit -> digit(grep)
      lexer.Word -> todo
    }
  }
  |> reverse(Match)
}

fn reverse(grep: Grep, reversed: Grep) -> Grep {
  case grep {
    Match -> reversed
    Literal(s, next) -> reverse(next, Literal(s, reversed))
    OneOf(greps, next) -> reverse(next, OneOf(greps, reversed))
  }
}

fn digit(next: Grep) -> Grep {
  list.range(from: 0, to: 9)
  |> list.map(int.to_string)
  |> list.map(Literal(_, Match))
  |> OneOf(next)
}
