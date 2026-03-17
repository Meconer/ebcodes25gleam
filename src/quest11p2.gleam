import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn quest(inp: String) {
  let ducks =
    inp
    |> string.split("\n")
    |> list.map(fn(ds) { int.parse(ds) |> result.unwrap(0) })
  let #(_, count) = do_phases(ducks)
  count
}

fn do_phases(ducks: List(Int)) {
  let #(after_phase_1, count) = do_phase1(ducks, 0)
  do_phase2(after_phase_1, count)
}

fn do_phase1(ducks: List(Int), round_count: Int) {
  let #(ducks, did_move) = move_ph_1(ducks, [], False)
  case did_move {
    True -> do_phase1(ducks, round_count + 1)
    False -> #(ducks, round_count)
  }
}

fn do_phase2(ducks: List(Int), round_count: Int) {
  let #(ducks, did_move) = move_ph_2(ducks, [], False)
  case did_move {
    True -> do_phase2(ducks, round_count + 1)
    False -> #(ducks, round_count)
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

pub const sample_input_2 = "805
706
179
48
158
150
232
885
598
524
423"

pub const input = "837018
339175
779209
715610
911938
526803
216740
849541
170706
178971
3852
916913
8111
2097
2224
385325
102395
725
993711
608384
593208
482085
1025
784311
2271
572804
656937
336366
806337
644055
903432
668816
788023
61577
996453
3518
675091
612174
866660
209939
289939
590436
567983
679470
483957
602897
7298
153200
5319
954932
703397
441038
93386
81547
677956
420971
924328
847838
841628
455790"
