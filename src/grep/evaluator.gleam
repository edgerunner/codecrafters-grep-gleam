import gleam/bool
import gleam/iterator.{type Iterator}
import gleam/result
import gleam/string
import grep/capture.{type Capture}
import grep/parser.{
  type Grep, Capture, Literal, Many, Match, Maybe, Not, OneOf, Reference,
}

pub fn run(string: String, pattern: Grep) -> Bool {
  let capture = capture.start()
  iterator.iterate(string, string.drop_left(_, 1))
  |> iterator.take_while(fn(s) { string.is_empty(s) |> bool.negate })
  |> iterator.flat_map(evaluate(_, pattern, capture))
  |> iterator.first
  |> result.is_ok
}

type Evaluation =
  Iterator(String)

fn evaluate(string: String, pattern: Grep, capture: Capture) -> Evaluation {
  let continue = fn(eval: Evaluation, next: Grep) {
    iterator.flat_map(eval, evaluate(_, next, capture))
  }

  case pattern {
    Match -> string |> iterator.single

    Literal(match, next) -> literal(string, match) |> continue(next)

    OneOf(greps, next) -> {
      one_of(string, greps, capture) |> continue(next)
    }

    Not(grep, next) -> not(string, grep, capture) |> continue(next)

    Many(grep, next) -> {
      many(string, grep, capture) |> continue(next)
    }

    Maybe(grep, next) -> maybe(string, grep, capture) |> continue(next)

    Reference(number, next) ->
      capture.get(capture, number)
      |> result.map(Literal(_, Match))
      |> result.map(evaluate(string, _, capture))
      |> result.unwrap(iterator.empty())
      |> continue(next)

    Capture(grep, number, next) -> {
      use possibility <- iterator.flat_map(evaluate(string, grep, capture))
      let captured_string =
        string.drop_right(string, string.length(possibility))
      capture.set(capture, number, captured_string)
      evaluate(possibility, next, capture)
    }
  }
}

fn literal(string: String, match: String) -> Evaluation {
  case string.starts_with(string, match) {
    True -> string |> string.drop_left(string.length(match)) |> iterator.single

    False -> iterator.empty()
  }
}

fn one_of(string: String, greps: List(Grep), capture: Capture) -> Evaluation {
  iterator.from_list(greps)
  |> iterator.flat_map(evaluate(string, _, capture))
}

fn not(string: String, grep: Grep, capture: Capture) -> Evaluation {
  let eval = evaluate(string, grep, capture)
  case iterator.first(eval) {
    Ok(_) -> iterator.empty()
    Error(_) -> string |> string.drop_left(1) |> iterator.single
  }
}

fn many(string: String, grep: Grep, capture: Capture) -> Evaluation {
  evaluate(string, grep, capture)
  |> iterator.flat_map(any(_, grep, capture))
}

fn any(string: String, grep: Grep, capture: Capture) -> Evaluation {
  use <- iterator.yield(string)
  many(string, grep, capture)
}

fn maybe(string: String, grep: Grep, capture: Capture) -> Evaluation {
  use <- iterator.yield(string)
  evaluate(string, grep, capture)
}
