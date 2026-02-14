import gleam/order
import gleeunit
import q4_inputs
import quest3
import quest4
import quest5
import quest6
import quest7

pub fn main() -> Nil {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
// pub fn q3p1_test() {
//   assert quest3.q3p1(quest3.sample_input_p1) == 29
// }

// pub fn q3p2_test() {
//   assert quest3.q3p2(quest3.sample_input_p2) == 781
// }

// pub fn q3p3_test() {
//   assert quest3.q3p3(quest3.sample_input_p3) == 3
// }

// pub fn q4p1_test() {
//   assert quest4.q4p1(q4_inputs.sample_input_2) == 15_888
// }

// pub fn q4p2_test() {
//   assert quest4.q4p2(q4_inputs.sample_input_1, 10_000_000_000_000)
//     == 625_000_000_000
// }

// pub fn q4p2_2_test() {
//   assert quest4.q4p2(q4_inputs.sample_input_2, 10_000_000_000_000)
//     == 1_274_509_803_922
// }

// pub fn q4p3_test() {
//   assert quest4.q4p3(q4_inputs.sample_input_3, 100) == 400
// }

// pub fn q4p3_2_test() {
//   assert quest4.q4p3(q4_inputs.sample_input_4, 100) == 6818
// }

// import q5_inputs

// pub fn q5p1_test() {
//   assert quest5.q5p1(q5_inputs.sample_input_1) == "581078"
// }

// pub fn q5p2_test() {
//   assert quest5.q5p2(q5_inputs.sample_input_2) == 77_053
// }

// pub fn fishbone_test() {
//   let test1_lst = [7, 1, 9, 1, 6, 9, 8, 3, 7, 2]
//   let tree1 = quest5.build_tree(test1_lst)
//   let fishbones = quest5.calc_fishbones(tree1, [])
//   assert fishbones == [179, 16, 89, 237]
// }

// pub fn fishbone_compare_test() {
//   let test1_lst = [7, 1, 9, 1, 6, 9, 8, 3, 7, 2]
//   let tree1 = quest5.build_tree(test1_lst)
//   let sword1 = quest5.Sword(1, tree1)
//   let test2_lst = [7, 1, 9, 1, 6, 9, 8, 3, 8, 2]
//   let tree2 = quest5.build_tree(test2_lst)
//   let sword2 = quest5.Sword(2, tree2)
//   let test3_lst = [7, 1, 9, 1, 6, 9, 8, 3, 6, 2]
//   let tree3 = quest5.build_tree(test3_lst)
//   let sword3 = quest5.Sword(3, tree3)
//   assert quest5.sword_compare(sword1, sword2) == order.Lt
//   assert quest5.sword_compare(sword1, sword3) == order.Gt
//   assert quest5.sword_compare(sword3, sword3) == order.Eq
// }

// pub fn q5p3_test() {
//   assert quest5.q5p3(q5_inputs.sample_input_3) == 260
// }

// pub fn q5p32_test() {
//   assert quest5.q5p3(q5_inputs.sample_input_32) == 4
// }

// pub fn q6p1_test() {
//   assert quest6.q6p1(quest6.sample_input_p1()) == 5
// }

// pub fn q6p2_test() {
//   assert quest6.q6p2(quest6.sample_input_p1()) == 11
// }

// pub fn q6p3_test() {
//   assert quest6.q6p3(quest6.sample_input_p3, 10, 1) == 34
//   assert quest6.q6p3(quest6.sample_input_p3, 10, 2) == 72
//   let res = quest6.q6p3(quest6.sample_input_p3, 1000, 1000)
//   let r1 = res - 3_442_321
//   echo r1
//   echo r1 / 2
//   assert res == 3_442_321
// }

pub fn q7p1_test() {
  let res = quest7.q7p1(quest7.words_sample_p1, quest7.rules_sample_p1)
  assert res == "Oroneth"
}

pub fn q7p2_test() {
  let res = quest7.q7p2(quest7.words_sample_p2, quest7.rules_sample_p2)
  assert res == 23
}
