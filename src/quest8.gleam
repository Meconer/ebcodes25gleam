import gleam/int
import gleam/list
import gleam/result
import gleam/string

fn parse_input(inp: #(Int, String)) -> #(Int, List(Int)) {
  let #(cnt, inp_str) = inp
  let lst =
    inp_str
    |> string.split(",")
    |> list.map(fn(el) { int.parse(el) |> result.unwrap(-1) })
  #(cnt, lst)
}

pub fn q8p1(inp) {
  let #(no_of_pts, pts) = parse_input(inp)
  0
}

pub const sample_input_1 = #(8, "1,5,2,6,8,4,1,7,3")
