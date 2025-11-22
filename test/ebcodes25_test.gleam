import gleeunit
import quest2

pub fn main() -> Nil {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn calc_cycles_p2_test() {
  let coord = #(35_630, -64_880)
  let res = quest2.calc_cycles_p2(coord, 100)
  assert res == #(#(-2520, -5355), 0)
}

pub fn calc_cycles_p2_2_test() {
  let coord = #(36_250, -64_270)
  let res = quest2.calc_cycles_p2(coord, 100)
  assert res == #(#(162_903, -679_762), 0)
}

pub fn calc_cycles_p2_3_test() {
  let coord = #(35_460, -64_910)
  let res = quest2.calc_cycles_p2(coord, 100)
  assert res == #(#(1_265_017, 932_533), 73)
}
