import gleam/result
import gleam/string
import grep/capture.{type Capture}
import grep/parser.{
  type Grep, Capture, Literal, Many, Match, Maybe, Not, OneOf, Reference,
}

pub fn run(string: String, pattern: Grep) -> Bool {
  let capture = capture.start()
  case evaluate(string, pattern, capture), string {
    Ok(_), _ -> True
    Error(_), "" -> False
    Error(True), _ -> False
    Error(False), _ -> string.drop_left(string, 1) |> run(pattern)
  }
}

fn evaluate(
  string: String,
  pattern: Grep,
  capture: Capture,
) -> Result(String, Bool) {
  case pattern {
    Match -> Ok(string)
    Literal(match, next) ->
      literal(string, match) |> result.then(evaluate(_, next, capture))

    OneOf(greps, next) -> {
      one_of(string, greps, capture) |> result.then(evaluate(_, next, capture))
    }

    Not(grep, next) ->
      not(string, grep, capture) |> result.then(evaluate(_, next, capture))

    Many(grep, next) ->
      many(string, grep, capture) |> result.then(evaluate(_, next, capture))

    Maybe(grep, next) ->
      maybe(string, grep, capture) |> result.then(evaluate(_, next, capture))

    Reference(number, next) ->
      capture.get(capture, number)
      |> result.replace_error(True)
      |> result.map(Literal(_, Match))
      |> result.then(evaluate(string, _, capture))
      |> result.then(evaluate(_, next, capture))

    Capture(grep, number, next) -> {
      use rest <- result.then(evaluate(string, grep, capture))
      let captured_string = string.drop_right(string, string.length(rest))
      capture.set(capture, number, captured_string)
      evaluate(rest, next, capture)
    }
  }
}

fn literal(string: String, match: String) -> Result(String, Bool) {
  case string.starts_with(string, match) {
    True -> string |> string.drop_left(string.length(match)) |> Ok
    False -> Error(False)
  }
}

fn one_of(
  string: String,
  greps: List(Grep),
  capture: Capture,
) -> Result(String, Bool) {
  case greps {
    [] -> Error(False)
    [grep, ..rest] ->
      case evaluate(string, grep, capture) {
        Ok(remaining) -> Ok(remaining)
        Error(True) -> Error(True)
        Error(False) -> one_of(string, rest, capture)
      }
  }
}

fn not(string: String, grep: Grep, capture: Capture) -> Result(String, Bool) {
  case evaluate(string, grep, capture) {
    Ok(_) -> Error(True)
    Error(False) -> string |> string.drop_left(1) |> Ok
    Error(True) -> Error(True)
  }
}

fn many(string: String, grep: Grep, capture: Capture) -> Result(String, Bool) {
  evaluate(string, grep, capture) |> result.then(any(_, grep, capture))
}

fn any(string: String, grep: Grep, capture: Capture) -> Result(String, Bool) {
  case evaluate(string, grep, capture) {
    Ok("") -> Ok("")
    Ok(remaining) -> any(remaining, grep, capture)
    Error(_) -> Ok(string)
  }
}

fn maybe(string: String, grep: Grep, capture: Capture) -> Result(String, Bool) {
  case evaluate(string, grep, capture) {
    Ok(remaining) -> Ok(remaining)
    Error(_) -> Ok(string)
  }
}
