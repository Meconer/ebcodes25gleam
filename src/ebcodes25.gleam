import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

// import quest1
import quest2

pub fn main() -> Nil {
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
