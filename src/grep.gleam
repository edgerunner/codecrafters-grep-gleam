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
      let grep = parser.parse(pattern)
      case match_pattern(input_line, grep) {
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

fn match_pattern(input_line: String, grep: parser.Grep) -> Bool {
  case evaluator.evaluate(input_line, grep), input_line {
    Ok(_), _ -> True
    Error(Nil), "" -> False
    Error(Nil), _ -> string.drop_left(input_line, 1) |> match_pattern(grep)
  }
}

@external(erlang, "erlang", "halt")
pub fn exit(code: Int) -> Int
