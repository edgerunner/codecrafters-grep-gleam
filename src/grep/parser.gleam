import gleam/int
import gleam/iterator
import gleam/list
import gleam/set.{type Set}
import gleam/string
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
      lexer.Word -> word(grep)
      lexer.PositiveCharacterGroup(characters) ->
        positive_character_group(characters, grep)
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

fn word(next: Grep) -> Grep {
  [alpha_upper(Match), alpha_lower(Match), digit(Match)]
  |> OneOf(next)
}

fn digit(next: Grep) -> Grep {
  list.range(from: 0, to: 9)
  |> list.map(int.to_string)
  |> list.map(Literal(_, Match))
  |> OneOf(next)
}

fn alpha_upper(next: Grep) -> Grep {
  list.range(from: 65, to: 90)
  |> list.filter_map(string.utf_codepoint)
  |> string.from_utf_codepoints
  |> string.to_graphemes
  |> list.map(Literal(_, Match))
  |> OneOf(next)
}

fn alpha_lower(next: Grep) -> Grep {
  list.range(from: 97, to: 122)
  |> list.filter_map(string.utf_codepoint)
  |> string.from_utf_codepoints
  |> string.to_graphemes
  |> list.map(Literal(_, Match))
  |> OneOf(next)
}

fn positive_character_group(characters: Set(String), next: Grep) -> Grep {
  set.to_list(characters)
  |> list.map(Literal(_, Match))
  |> OneOf(next)
}
