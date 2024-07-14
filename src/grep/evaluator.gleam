import gleam/result
import gleam/string
import grep/parser.{type Grep, Literal, Match, Not, OneOf}

pub fn evaluate(string: String, pattern: Grep) -> Result(String, Bool) {
  case pattern {
    Match -> Ok(string)
    Literal(match, next) ->
      literal(string, match) |> result.then(evaluate(_, next))

    OneOf(greps, next) -> {
      one_of(string, greps) |> result.then(evaluate(_, next))
    }

    Not(grep, Match) ->
      case not(string, grep) {
        Error(e) -> Error(e)
        Ok("") -> Ok("")
        Ok(_) -> Error(False)
      }
    Not(grep, next) -> not(string, grep) |> result.then(evaluate(_, next))
  }
}

fn literal(string: String, match: String) -> Result(String, Bool) {
  case string.starts_with(string, match) {
    True -> string |> string.drop_left(string.length(match)) |> Ok
    False -> Error(False)
  }
}

fn one_of(string: String, greps: List(Grep)) -> Result(String, Bool) {
  case greps {
    [] -> Error(False)
    [grep, ..rest] ->
      case evaluate(string, grep) {
        Ok(remaining) -> Ok(remaining)
        Error(True) -> Error(True)
        Error(False) -> one_of(string, rest)
      }
  }
}

fn not(string: String, grep: Grep) -> Result(String, Bool) {
  case evaluate(string, grep) {
    Ok(_) -> Error(True)
    Error(_) -> string |> string.drop_left(1) |> Ok
  }
}
