import gleam/list
import gleam/result
import gleam/string
import grep/parser.{type Grep, Literal, Match, Not, OneOf}

pub fn evaluate(string: String, pattern: Grep) -> Result(String, Nil) {
  case pattern {
    Match -> Ok(string)
    Literal(match, next) ->
      literal(string, match) |> result.then(evaluate(_, next))

    OneOf(greps, next) -> {
      one_of(string, greps) |> result.then(evaluate(_, next))
    }

    Not(grep, next) -> todo
  }
}

fn literal(string: String, match: String) -> Result(String, Nil) {
  case string.starts_with(string, match) {
    True -> string |> string.drop_left(string.length(match)) |> Ok
    False -> Error(Nil)
  }
}

fn one_of(string: String, greps: List(Grep)) -> Result(String, Nil) {
  use grep <- list.find_map(greps)
  evaluate(string, grep)
}
