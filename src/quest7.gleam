import gleam/dict
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
    |> dict.from_list()
  list.map(words, fn(word) { check_word(word, rules) })
}

fn rec_check(wlst: List(String), rules, is_ok) {
  case wlst {
    [] -> is_ok
    [_] -> is_ok
    [a, b, ..tail] -> {
      case is_pair_in_order(a, b, rules) {
        True -> rec_check(tail, rules, is_ok)
        False -> False
      }
    }
  }
}

fn is_pair_in_order(
  a: String,
  b: String,
  rules: dict.Dict(String, List(String)),
) -> Bool {
  let ok_list = dict.get(rules, a)
  case ok_list {
    Ok(list) -> list.contains(list, b)
    _ -> False
  }
}

fn check_word(word: String, rules: dict.Dict(String, List(String))) {
  string.to_graphemes(word)
  |> rec_check(rules, True)
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
