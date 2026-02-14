pub fn unsafe_list_first(lst: List(a)) -> a {
  case lst {
    [] -> panic as "empty list"
    [first, ..] -> first
  }
}
