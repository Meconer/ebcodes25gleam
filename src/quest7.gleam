import gleam/list
import gleam/string

pub fn q7p1(words: String, rules: String) {
  let words = words |> string.split(",") |> echo
  let rules =
    rules
    |> string.split("\n")
    |> list.fold([], fn(acc, line) {
      let parts = string.split(line, on: " > ")
      let assert Ok(pre) = list.first(parts)
      let assert Ok(post_str) = list.last(parts)
      let posts = string.split(post_str, ",")
      [#(pre, posts), ..acc]
    })
    |> echo
}

pub const words_sample_p1 = "Oronris,Urakris,Oroneth,Uraketh"

pub const rules_sample_p1 = "r > a,i,o
i > p,w
n > e,r
o > n,m
k > f,r
a > k
U > r
e > t
O > r
t > h"
