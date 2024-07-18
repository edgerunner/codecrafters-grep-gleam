//// Very simple key-value store process for storing captured strings

import gleam/dict.{type Dict}
import gleam/erlang/process
import gleam/otp/actor

pub opaque type Msg {
  Set(key: Int, value: String)
  Get(key: Int, subject: process.Subject(Result(String, Nil)))
  Stop
}

pub type Capture =
  process.Subject(Msg)

pub fn start() -> Capture {
  let assert Ok(capture) = actor.start(dict.new(), loop)
  capture
}

pub fn set(subject: Capture, key: Int, value: String) {
  actor.send(subject, Set(key, value))
}

pub fn get(subject: Capture, key: Int) -> Result(String, Nil) {
  actor.call(subject, Get(key, _), 100)
}

pub fn stop(subject: Capture) {
  actor.send(subject, Stop)
}

fn loop(msg: Msg, store: Dict(Int, String)) {
  case msg {
    Set(key, value) -> {
      dict.insert(into: store, for: key, insert: value)
      |> actor.continue
    }
    Get(key, subject) -> {
      dict.get(store, key) |> actor.send(subject, _)
      actor.continue(store)
    }
    Stop -> {
      actor.Stop(process.Normal)
    }
  }
}
