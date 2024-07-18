import argv
import gleam/erlang
import gleam/io
import gleam/string
import grep/evaluator
import grep/parser

const stx = "\u{2}"

const etx = "\u{3}"

pub fn main() {
  let args = argv.load().arguments
  let assert Ok(input_line) = erlang.get_line("")

  case args {
    ["-E", pattern, ..] -> {
      let grep = parser.parse(pattern)
      let marked_input = stx <> input_line <> etx
      case evaluator.run(marked_input, grep) {
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

@external(erlang, "erlang", "halt")
pub fn exit(code: Int) -> Int
