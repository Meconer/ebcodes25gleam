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

pub fn q8p1(inp: #(Int, String)) -> Int {
  let #(no_of_pts, pts) = parse_input(inp)
  list.window_by_2(pts)
  |> list.count(fn(tp) {
    let #(pt1, pt2) = tp
    int.absolute_value(pt2 - pt1) == no_of_pts / 2
  })
}

pub const sample_input_1 = #(8, "1,5,2,6,8,4,1,7,3")

pub const q8_input_1 = #(
  32,
  "1,32,19,3,19,3,19,3,19,3,17,1,17,3,19,3,19,2,18,2,21,1,17,1,19,3,22,6,24,8,24,8,24,5,25,9,22,6,22,6,22,6,19,1,13,29,12,31,18,3,15,30,14,28,12,28,12,30,12,24,11,27,11,27,11,24,6,22,6,22,6,22,6,22,6,23,7,23,7,27,11,28,15,31,17,2,19,6,23,7,23,11,27,11,27,7,23,7,22,4",
)
