import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn quest(inp: String) {
  let ducks =
    inp
    |> string.split("\n")
    |> list.map(fn(ds) { int.parse(ds) |> result.unwrap(0) })
    |> echo
  let #(balanced_ducks, _) = do_phases(ducks)
  calc_checksum(balanced_ducks)
}

fn calc_checksum(balanced_ducks: List(Int)) -> Int {
  list.index_fold(balanced_ducks, 0, fn(acc, el, idx) { { idx + 1 } * el + acc })
}

fn do_phases(ducks: List(Int)) {
  let #(after_phase_1, no_of_rounds_left) = do_phase1(ducks, 9) |> echo
  do_phase2(after_phase_1, no_of_rounds_left) |> echo
}

fn do_phase1(ducks: List(Int), no_of_rounds: Int) {
  let #(ducks, did_move) = move_ph_1(ducks, [], False)
  case did_move, no_of_rounds {
    True, no_of_rounds if no_of_rounds > 0 -> do_phase1(ducks, no_of_rounds - 1)
    False, _ -> #(ducks, no_of_rounds)
    True, 0 -> #(ducks, 0)
    True, _ -> panic as "This can not be negative"
  }
}

fn do_phase2(ducks: List(Int), no_of_rounds: Int) {
  let #(ducks, did_move) = move_ph_2(ducks, [], False)
  case did_move, no_of_rounds {
    True, no_of_rounds if no_of_rounds > 0 -> do_phase2(ducks, no_of_rounds - 1)
    True, 0 -> #(ducks, 0)
    True, _ -> panic as "Negative in phase 2"
    False, _ -> #(ducks, no_of_rounds)
  }
}

fn move_ph_1(ducks: List(Int), acc: List(Int), did_move: Bool) {
  case ducks {
    [last] -> #(list.append(acc, [last]), did_move)
    [a, b, ..rest] -> {
      case a > b {
        True -> {
          let acc = list.append(acc, [a - 1])
          move_ph_1([b + 1, ..rest], acc, True)
        }
        False -> {
          let acc = list.append(acc, [a])
          move_ph_1([b, ..rest], acc, did_move)
        }
      }
    }
    [] -> panic as "Should not happen"
  }
}

fn move_ph_2(ducks: List(Int), acc: List(Int), did_move: Bool) {
  case ducks {
    [last] -> #(list.append(acc, [last]), did_move)
    [a, b, ..rest] -> {
      case a < b {
        True -> {
          let acc = list.append(acc, [a + 1])
          move_ph_2([b - 1, ..rest], acc, True)
        }
        False -> {
          let acc = list.append(acc, [a])
          move_ph_2([b, ..rest], acc, did_move)
        }
      }
    }
    [] -> panic as "Should not happen"
  }
}

pub const sample_input_1 = "9
1
1
4
9
6"

pub const q11_input_1 = "1
11
17
18
19
12"
