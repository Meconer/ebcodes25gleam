import gleam/int
import gleam/io
import gleam/list
import gleam/string
import q5_inputs
import quest6
import quest7
import quest8
import quest9
import simplifile

// import quest1
import quest2

pub fn q2() -> Nil {
  io.println("Q2p1:")
  echo quest2.q2p1()
  io.println("Q2p2:")
  echo quest2.q2p2()
  io.println("Q2p3:")
  let res = quest2.q2p3()
  let #(cnt, output) = res
  io.println("White pixel count: " <> int.to_string(cnt))
  let outstring = output |> list.reverse |> string.join("\n")
  let assert Ok(Nil) =
    simplifile.write(to: "output_p3.ppm", contents: outstring)

  Nil
}

import quest3

pub fn q3() -> Nil {
  io.println("Q3p1:")
  echo quest3.q3p1(quest3.input_p1)
  io.println("Q3p2:")
  echo quest3.q3p2(quest3.input_p2)
  io.println("Q3p3:")
  echo quest3.q3p3(quest3.input_p3)
  Nil
}

import q4_inputs
import quest4

pub fn q4() -> Nil {
  io.print("Q4p1: ")
  io.println(quest4.q4p1(q4_inputs.input_p1) |> int.to_string)
  io.print("Q4p2: ")
  io.println(
    quest4.q4p2(q4_inputs.input_p2, 10_000_000_000_000) |> int.to_string,
  )
  io.print("Q4p3: ")
  io.println(quest4.q4p3(q4_inputs.input_p3, 100) |> int.to_string)
  Nil
}

import quest5

pub fn q5() -> Nil {
  io.print("Q5p1: ")
  io.println(quest5.q5p1(q5_inputs.input_p1))
  io.print("Q5p2: ")
  io.println(quest5.q5p2(q5_inputs.input_p2) |> int.to_string)
  io.print("Q5p3: ")
  io.println(quest5.q5p3(q5_inputs.input_p3) |> int.to_string)
  Nil
}

pub fn q6() -> Nil {
  io.print("Q6p1: ")
  io.println(quest6.q6p1(quest6.input_p1()) |> int.to_string)
  io.print("Q6p2: ")
  io.println(quest6.q6p2(quest6.input_p2()) |> int.to_string)
  io.print("Q6p3: ")
  io.println(quest6.q6p3(quest6.input_p3, 1000, 1000) |> int.to_string)
  Nil
}

pub fn q7() -> Nil {
  io.print("Q7p1: ")
  io.println(quest7.q7p1(quest7.words_p1, quest7.rules_p1))
  io.print("Q7p2: ")
  io.println(quest7.q7p2(quest7.words_p2, quest7.rules_p2) |> int.to_string())
  io.print("Q7p3: ")
  io.println(
    quest7.q7p3count(quest7.words_p3, quest7.rules_p3) |> int.to_string(),
  )
  Nil
}

pub fn q8() -> Nil {
  io.print("Q8p1: ")
  io.println(quest8.q8p1(quest8.q8_input_1) |> int.to_string)
  io.print("Q8p2: ")
  io.println(quest8.q8p2(quest8.q8_input_2) |> int.to_string)
  io.print("Q8p3: ")
  io.println(quest8.q8p3(quest8.q8_input_3) |> int.to_string())
  Nil
}

pub fn q9() -> Nil {
  io.print("Q9p1: ")
  io.println(quest9.q9p1(quest9.q9_input_1) |> int.to_string)
  // io.print("Q8p2: ")
  // io.println(quest8.q8p2(quest8.q8_input_2) |> int.to_string)
  // io.print("Q8p3: ")
  // io.println(quest8.q8p3(quest8.q8_input_3) |> int.to_string())
  Nil
}

pub fn main() -> Nil {
  q9()
  Nil
}
