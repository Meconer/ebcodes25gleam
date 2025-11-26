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

fn get_input_p3(input) {
  input()
  |> string.split(on: "\n")
  |> list.map(fn(s) {
    case string.split(s, on: "|") {
      [num_str] -> {
        case int.parse(num_str) {
          Ok(i) -> #(i, i)
          Error(_) -> panic as "Wrong input"
        }
      }
      [num_str1, num_str2] -> {
        let n1 = case int.parse(num_str1) {
          Ok(i) -> i
          Error(_) -> panic as "Wrong input"
        }
        let n2 = case int.parse(num_str2) {
          Ok(i) -> i
          Error(_) -> panic as "Wrong input"
        }
        #(n1, n2)
      }
      _ -> panic as "Wrong input format"
    }
  })
}

pub fn q4p3(input) {
  let numbers = get_input_p3(input)

  echo numbers
  list.fold(numbers, 1.0, fn(acc, tup) {
    let #(n1, n2) = tup
    let f1 = int.to_float(n1)
    let f2 = int.to_float(n2)
    acc *. f2 /. f1
  })
}
