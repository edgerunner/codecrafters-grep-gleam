import birdie
import grep/evaluator
import grep/parser
import pprint

pub fn a_match_a_test() {
  snap_match(string: "a", pattern: "a")
}

pub fn s_no_match_a_test() {
  snap_no_match(string: "s", pattern: "a")
}

pub fn asd_match_a_test() {
  snap_match(string: "asd", pattern: "a")
}

pub fn bad_no_match_a_test() {
  snap_no_match(string: "bad", pattern: "a")
}

pub fn digit_2_match_test() {
  snap_match(string: "2", pattern: "\\d")
}

pub fn digit_q_no_match_test() {
  snap_no_match(string: "q", pattern: "\\d")
}

pub fn word_2_match_test() {
  snap_match(string: "2", pattern: "\\w")
}

pub fn word_q_match_test() {
  snap_match(string: "q", pattern: "\\w")
}

pub fn word_capital_s_match_test() {
  snap_match(string: "S", pattern: "\\w")
}

pub fn word_star_no_match_test() {
  snap_no_match(string: "*", pattern: "\\w")
}

fn snap_match(string string, pattern pattern) {
  parser.parse(pattern)
  |> evaluator.evaluate(string, _)
  |> pprint.format
  |> birdie.snap(pattern <> " matches " <> string)
}

fn snap_no_match(string string, pattern pattern) {
  parser.parse(pattern)
  |> evaluator.evaluate(string, _)
  |> pprint.format
  |> birdie.snap(pattern <> " does not match " <> string)
}
