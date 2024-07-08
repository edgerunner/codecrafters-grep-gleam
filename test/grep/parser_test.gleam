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
