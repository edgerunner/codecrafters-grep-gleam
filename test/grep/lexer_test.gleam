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

pub fn lex_word_class_test() {
  lexer.lex("\\w")
  |> iterator.to_list
  |> pprint.format
  |> birdie.snap("Lex word class")
}

pub fn lex_literals_and_classes_test() {
  lexer.lex("R\\d\\w\\d")
  |> iterator.to_list
  |> pprint.format
  |> birdie.snap("Lex literals and classes")
}

pub fn lex_positive_character_group_test() {
  lexer.lex("[abc]")
  |> iterator.to_list
  |> pprint.format
  |> birdie.snap("Lex positive character group abc")
}

pub fn lex_negative_character_group_test() {
  lexer.lex("[^abc]")
  |> iterator.to_list
  |> pprint.format
  |> birdie.snap("Lex negative character group abc")
}

pub fn lex_literal_brackets_test() {
  lexer.lex("\\[abc\\]")
  |> iterator.to_list
  |> pprint.format
  |> birdie.snap("Lex literal brackets")
}
