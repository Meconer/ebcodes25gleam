import gleeunit
import q4_inputs
import quest3
import quest4

pub fn main() -> Nil {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn q3p1_test() {
  assert quest3.q3p1(quest3.sample_input_p1) == 29
}

pub fn q3p2_test() {
  assert quest3.q3p2(quest3.sample_input_p2) == 781
}

pub fn q3p3_test() {
  assert quest3.q3p3(quest3.sample_input_p3) == 3
}

pub fn q4p1_test() {
  assert quest4.q4p1(q4_inputs.sample_input_2) == 15_888
}

pub fn q4p2_test() {
  assert quest4.q4p2(q4_inputs.sample_input_1, 10_000_000_000_000)
    == 625_000_000_000
}

pub fn q4p2_2_test() {
  assert quest4.q4p2(q4_inputs.sample_input_2, 10_000_000_000_000)
    == 1_274_509_803_922
}

pub fn q4p3_test() {
  assert quest4.q4p3(q4_inputs.sample_input_3, 100) == 400
}

pub fn q4p3_2_test() {
  assert quest4.q4p3(q4_inputs.sample_input_4, 100) == 6818
}
