import gleeunit/should
import grep/capture

pub fn capture_stores_given_value_test() {
  let capture = capture.start()

  capture.set(capture, 3, "three")
  capture.get(capture, 3)
  |> should.be_ok
  |> should.equal("three")

  capture.stop(capture)
}

pub fn capture_errors_on_unused_key_test() {
  let capture = capture.start()

  capture.set(capture, 3, "three")
  capture.get(capture, 2)
  |> should.be_error

  capture.stop(capture)
}
