import birdie
import gleam/iterator
import grep/lexer
import pprint

pub fn lex_literal_character_test() {
  lexer.lex("s")
  |> iterator.to_list
  |> pprint.format
  |> birdie.snap("Lex the literal character s")
}

pub fn lex_digit_class_test() {
  lexer.lex("\\d")
  |> iterator.to_list
  |> pprint.format
  |> birdie.snap("Lex digit class")
}

pub fn lex_literal_with_digit_test() {
  lexer.lex("A\\d")
  |> iterator.to_list
  |> pprint.format
  |> birdie.snap("Lex literal with digit")
}

pub fn lex_literals_and_digits_test() {
  lexer.lex("R\\dD\\d")
  |> iterator.to_list
  |> pprint.format
  |> birdie.snap("Lex literals and digits")
}
