import birdie
import gleam/iterator
import gleam/list
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

pub fn lex_start_anchor_test() {
  lexer.lex("^abc")
  |> iterator.to_list
  |> pprint.format
  |> birdie.snap("Lex start anchor")
}

pub fn lex_literal_caret_test() {
  lexer.lex("ab^c")
  |> iterator.to_list
  |> pprint.format
  |> birdie.snap("Lex literal caret without escape")
}

pub fn lex_escaped_caret_test() {
  lexer.lex("\\^abc")
  |> iterator.to_list
  |> pprint.format
  |> birdie.snap("Lex literal caret with escape")
}

pub fn lex_end_anchor_test() {
  lexer.lex("abc$")
  |> iterator.to_list
  |> pprint.format
  |> birdie.snap("Lex end anchor")
}

pub fn lex_escaped_dollar_test() {
  lexer.lex("abc\\$")
  |> iterator.to_list
  |> pprint.format
  |> birdie.snap("Lex literal dollar sign with escape")
}

pub fn lex_capture_group_test() {
  lexer.lex("(cat|dog|mouse)")
  |> iterator.to_list
  |> pprint.format
  |> birdie.snap("Lex capture group")
}

pub fn lex_capture_group_1_test() {
  let assert Ok(lexer.Capture([first, ..])) =
    lexer.lex("(cat|dog|mouse)")
    |> iterator.to_list
    |> list.first

  iterator.to_list(first)
  |> pprint.format
  |> birdie.snap("Lex first option in capture group")
}

pub fn lex_capture_group_with_inner_group_test() {
  let assert [lexer.Capture(parts)] =
    lexer.lex("([bc]at|dog|mouse)")
    |> iterator.to_list

  list.map(parts, iterator.to_list)
  |> pprint.format
  |> birdie.snap("Lex first option with inner group in capture group")
}

pub fn lex_backreference_test() {
  lexer.lex("(a|b) \\1")
  |> iterator.to_list
  |> pprint.format
  |> birdie.snap("Lex backreference")
}

pub fn lex_complex_backreference_test() {
  lexer.lex("(\\w\\w\\w\\w \\d\\d\\d) is doing \\1 times")
  |> iterator.to_list
  |> pprint.format
  |> birdie.snap("Lex complex backreference")
}

pub fn lex_captured_complex_contents_test() {
  let assert Ok(lexer.Capture([first, ..])) =
    lexer.lex("([abcd]+) is \\1, not [^xyz]+")
    |> iterator.first

  iterator.to_list(first)
  |> pprint.format
  |> birdie.snap("Lex captured complex contents")
}
