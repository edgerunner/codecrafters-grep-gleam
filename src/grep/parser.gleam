import gleam/int
import gleam/iterator
import gleam/list
import gleam/string
import grep/lexer

pub type Grep {
  /// This is the end of a chain. If you reach this, you have a match
  Match
  /// Match a literal string verbatim
  Literal(String, next: Grep)
  /// Match any one of the choices
  OneOf(List(Grep), next: Grep)
  /// Match anything but this
  Not(Grep, next: Grep)
  /// Match at least one instance
  Many(Grep, next: Grep)
  /// Match zero or one instance
  Maybe(Grep, next: Grep)
}

/// Start-of-text control character
const stx = "\u{2}"

/// End-of-text control character
const etx = "\u{3}"

pub fn parse(source: String) -> Grep {
  {
    use grep, token <- iterator.fold(over: lexer.lex(source), from: Match)
    case token {
      lexer.Literal(s) -> Literal(s, grep)
      lexer.Digit -> digit(grep)
      lexer.Word -> word(grep)
      lexer.PositiveCharacterGroup(characters) ->
        character_group(characters, grep)
      lexer.NegativeCharacterGroup(characters) ->
        character_group(characters, Match) |> Not(grep)
      lexer.StartAnchor -> Literal(stx, grep)
      lexer.EndAnchor -> Literal(etx, grep)
      lexer.OneOrMore -> {
        let #(head, tail) = uncons(grep)
        Many(head, tail)
      }
      lexer.OneOrNone -> {
        let #(head, tail) = uncons(grep)
        Maybe(head, tail)
      }
      lexer.Wildcard ->
        Not(OneOf([Literal(stx, Match), Literal(etx, Match)], Match), grep)
      lexer.Capture(_) -> todo
    }
  }
  |> reverse(Match)
}

fn reverse(grep: Grep, reversed: Grep) -> Grep {
  case grep {
    Match -> reversed
    Literal(s, next) -> reverse(next, Literal(s, reversed))
    OneOf(greps, next) -> reverse(next, OneOf(greps, reversed))
    Not(grep, next) -> reverse(next, Not(grep, reversed))
    Many(grep, next) -> reverse(next, Many(grep, reversed))
    Maybe(grep, next) -> reverse(next, Maybe(grep, reversed))
  }
}

fn uncons(grep: Grep) -> #(Grep, Grep) {
  case grep {
    Match -> #(Match, Match)
    Literal(x, next) -> #(Literal(x, Match), next)
    OneOf(x, next) -> #(OneOf(x, Match), next)
    Not(x, next) -> #(Not(x, Match), next)
    Many(x, next) -> #(Many(x, Match), next)
    Maybe(x, next) -> #(Maybe(x, Match), next)
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

fn character_group(characters: List(String), next: Grep) -> Grep {
  characters
  |> list.map(Literal(_, Match))
  |> OneOf(next)
}
