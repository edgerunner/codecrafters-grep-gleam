//// # Qmatic
////
//// `Qmatic` is a simple queue counter actor that starts at 1
//// and increments its internal counter every time it issues
//// a queue number

import gleam/erlang/process
import gleam/otp/actor

pub opaque type Qmatic {
  Next(process.Subject(Int))
  Stop
}

pub type Subject =
  process.Subject(Qmatic)

/// Gets and increments the queue number
pub fn next(qmatic: Subject) -> Int {
  actor.call(qmatic, Next, 100)
}

/// Starts a new `Qmatic` actor, starting at 1
pub fn start() -> Subject {
  let assert Ok(qmatic) = actor.start(1, loop)
  qmatic
}

/// Stops the `Qmatic` process
pub fn stop(qmatic: Subject) {
  actor.send(qmatic, Stop)
}

fn loop(msg: Qmatic, number: Int) {
  case msg {
    Next(caller) -> {
      actor.send(caller, number)
      actor.continue(number + 1)
    }
    Stop -> {
      actor.Stop(process.Normal)
    }
  }
}
