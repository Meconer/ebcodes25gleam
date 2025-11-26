import gleam/int
import gleam/list
import gleam/string

fn get_numbers(input) {
  input()
  |> string.split(on: "\n")
  |> list.map(fn(s) {
    case int.parse(s) {
      Ok(i) -> i
      Error(_) -> panic as "Wrong input"
    }
  })
}

pub fn q4p1(input) {
  let numbers = get_numbers(input)
  case numbers {
    [] -> panic as "Empty list"
    [a, ..] -> {
      let b = case list.last(numbers) {
        Ok(v) -> v
        Error(_) -> panic as "Empty list"
      }
      2025 * a / b
    }
  }
}

pub fn q4p2(input, wanted_turns: Int) {
  let numbers = get_numbers(input)
  case numbers {
    [] -> panic as "Empty list"
    [a, ..] -> {
      let b = case list.last(numbers) {
        Ok(v) -> v
        Error(_) -> panic as "Empty list"
      }
      let try = wanted_turns * b / a
      let recalc = try * a / b
      case recalc == wanted_turns {
        True -> try
        False -> try + 1
      }
    }
  }
}

pub fn q3p3(input) {
  input()
  |> string.split(on: ",")
  |> list.map(fn(s) {
    case int.parse(s) {
      Ok(i) -> i
      Error(_) -> panic as "Wrong input"
    }
  })
  |> list.sort(int.compare)
  |> list.chunk(fn(n) { n })
  |> list.map(fn(chunk) { list.length(chunk) })
  |> list.fold(0, int.max)
}
