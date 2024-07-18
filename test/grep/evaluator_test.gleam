import gleeunit/should
import grep/evaluator
import grep/parser

pub fn a_match_a_test() {
  match(string: "a", pattern: "a")
}

pub fn s_no_match_a_test() {
  no_match(string: "s", pattern: "a")
}

pub fn asd_match_a_test() {
  match(string: "asd", pattern: "a")
}

pub fn bad_match_a_test() {
  match(string: "bad", pattern: "a")
}

pub fn digit_2_match_test() {
  match(string: "2", pattern: "\\d")
}

pub fn digit_q_no_match_test() {
  no_match(string: "q", pattern: "\\d")
}

pub fn word_2_match_test() {
  match(string: "2", pattern: "\\w")
}

pub fn word_q_match_test() {
  match(string: "q", pattern: "\\w")
}

pub fn word_capital_s_match_test() {
  match(string: "S", pattern: "\\w")
}

pub fn word_star_no_match_test() {
  no_match(string: "*", pattern: "\\w")
}

pub fn negative_character_group_no_match_test() {
  no_match(string: "\u{2}banana\u{3}", pattern: "[^anb]")
}

pub fn capture_group_test() {
  match(string: "catastrophe", pattern: "(dog|cat|mouse)")
}

pub fn capture_group_with_inner_parts_test() {
  match(string: "batman", pattern: "(dog|[bc]at)")
}

pub fn capture_group_with_tail_test() {
  match(string: "tomcat", pattern: "(pussy|tom)cat")
}

pub fn backreference_match_test() {
  match(string: "tintin", pattern: "(tin)\\1")
}

pub fn backreference_no_match_test() {
  no_match(string: "tinder", pattern: "(tin)\\1")
}

/// this is from a failed codecrafters test
pub fn complex_backreference_match_test() {
  match(
    string: "grep 101 is doing grep 101 times",
    pattern: "(\\w\\w\\w\\w \\d\\d\\d) is doing \\1 times",
  )
}

/// this is from a failed codecrafters test
pub fn complex_capture_match_test() {
  match(
    string: "abcd is abcd, not efg",
    pattern: "([abcd]+) is \\1, not [^xyz]+",
  )
}

fn match(string string, pattern pattern) {
  parser.parse(pattern)
  |> evaluator.run(string, _)
  |> should.be_true
}

fn no_match(string string, pattern pattern) {
  parser.parse(pattern)
  |> evaluator.run(string, _)
  |> should.be_false
}
