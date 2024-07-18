import gleeunit/should
import qmatic

pub fn qmatic_returns_incremental_numbers_test() {
  let qmatic = qmatic.start()

  qmatic.next(qmatic) |> should.equal(1)
  qmatic.next(qmatic) |> should.equal(2)
  qmatic.next(qmatic) |> should.equal(3)
}
