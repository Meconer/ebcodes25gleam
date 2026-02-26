import gleam/int
import gleam/list

pub fn unsafe_list_first(lst: List(a)) -> a {
  case lst {
    [] -> panic as "empty list"
    [first, ..] -> first
  }
}

pub fn unsafe_list_last(lst: List(a)) -> a {
  case list.last(lst) {
    Ok(el) -> el
    Error(_) -> panic as "error in unsafe_list_last"
  }
}

pub fn unsafe_int_parse(s: String) -> Int {
  case int.parse(s) {
    Ok(n) -> n
    Error(_) -> panic as "error in unsafe_int_parse"
  }
}
