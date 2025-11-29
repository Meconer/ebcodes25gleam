import gleam/int
import gleam/io
import gleam/list
import gleam/string
import q5_inputs
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

  echo quest5.q5p1(q5_inputs.input_p1)
  // io.println(quest5.q5p1(q5_inputs.sample_input_1))
  // io.print("Q5p2: ")
  // io.println(
  //   quest5.q5p2(q4_inputs.input_p2, 10_000_000_000_000) |> int.to_string,
  // )
  // io.print("Q4p3: ")
  // io.println(quest4.q4p3(q4_inputs.input_p3, 100) |> int.to_string)
  Nil
}

pub fn main() -> Nil {
  q5()
  Nil
}
