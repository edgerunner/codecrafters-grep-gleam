import argv
import gleam/erlang
import gleam/io
import gleam/string
import grep/evaluator
import grep/parser

pub fn main() {
  let args = argv.load().arguments
  let assert Ok(input_line) = erlang.get_line("")

  case args {
    ["-E", pattern, ..] -> {
      case match_pattern(input_line, pattern) {
        True -> exit(0)
        False -> exit(1)
      }
    }
    _ -> {
      io.println("Expected first argument to be '-E'")
      exit(1)
    }
  }
}

fn match_pattern(input_line: String, pattern: String) -> Bool {
  case parser.parse(pattern) |> evaluator.evaluate(input_line, _) {
    Ok(_) -> True
    _ -> False
  }
}

@external(erlang, "erlang", "halt")
pub fn exit(code: Int) -> Int
