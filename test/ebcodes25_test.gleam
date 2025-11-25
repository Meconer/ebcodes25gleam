import gleeunit
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
  assert quest4.q4p1(quest4.sample_input_p1) == 32_400.0
}
