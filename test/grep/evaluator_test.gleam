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
