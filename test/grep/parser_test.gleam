import birdie
import grep/parser
import pprint

pub fn parse_literal_character_test() {
  parser.parse("s")
  |> pprint.format
  |> birdie.snap("Parse the literal character s")
}

pub fn parse_single_digit_class_test() {
  parser.parse("\\d")
  |> pprint.format
  |> birdie.snap("Parse single digit class")
}

pub fn parse_literal_with_digit_test() {
  parser.parse("A\\d")
  |> pprint.format
  |> birdie.snap("Parse literal with digit")
}

pub fn parse_literals_and_digits_test() {
  parser.parse("R\\dD\\d")
  |> pprint.format
  |> birdie.snap("Parse literals and digits")
}

pub fn parse_single_word_class_test() {
  parser.parse("\\w")
  |> pprint.format
  |> birdie.snap("Parse single word class")
}

pub fn parse_literals_and_classes_test() {
  parser.parse("R\\d\\w2")
  |> pprint.format
  |> birdie.snap("Parse literals and classes: R\\d\\w2")
}

pub fn parse_positive_character_group_abc_test() {
  parser.parse("[abc]")
  |> pprint.format
  |> birdie.snap("Parse positive character group abc")
}

pub fn parse_negative_character_group_abc_test() {
  parser.parse("[^abc]")
  |> pprint.format
  |> birdie.snap("Parse negative character group abc")
}

pub fn parse_start_of_text_anchor_abc_test() {
  parser.parse("^abc")
  |> pprint.format
  |> birdie.snap("Parse start-of-text anchor")
}

pub fn parse_end_of_text_anchor_abc_test() {
  parser.parse("abc$")
  |> pprint.format
  |> birdie.snap("Parse end-of-text anchor")
}
