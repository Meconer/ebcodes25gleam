import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

pub type Direction {
  Left
  Right
}

pub type Instruction {
  Instruction(dir: Direction, steps: Int)
}

fn get_int(s: String) -> Int {
  let r_i = int.parse(s)
  case r_i {
    Ok(i) -> i
    Error(_) -> panic as "Error!"
  }
}

fn decode_instr(instr: String) -> Instruction {
  case instr {
    "L" <> steps_str -> Instruction(dir: Left, steps: get_int(steps_str))
    "R" <> steps_str -> Instruction(dir: Right, steps: get_int(steps_str))
    _ -> panic as "Error!"
  }
}

fn input_p1() {
  "Vyrdax,Drakzyph,Fyrryn,Elarzris

R3,L2,R3,L1"
}

fn input_p2() {
  "Vanidris,Mornnyn,Gorathulrix,Hyravash,Ulkzyph,Sarzeth,Thazketh,Voraxxaril,Zaloryx,Ozankynar,Qalfarin,Iskarnylor,Phyrloris,Oryhynd,Paldselor,Vyrldaros,Vaelzal,Tazmal,Rythzyph,Tirphor

L18,R11,L17,R14,L16,R10,L19,R8,L17,R7,L5,R13,L5,R12,L5,R10,L5,R5,L5,R16,L17,R11,L12,R18,L19,R10,L8,R9,L12"
}

fn parse_input(input: String) -> #(List(String), List(Instruction)) {
  let lines = input |> string.split("\n\n")
  let #(namesstr, instrsstr) = case lines {
    [namesstr, instrsstr] -> #(namesstr, instrsstr)

    _ -> #("", "")
  }
  let names = namesstr |> string.split(",")

  let instrs =
    instrsstr
    |> string.split(",")
    |> list.map(decode_instr)
  #(names, instrs)
}

fn clamp(i: Int, max: Int) -> Int {
  int.max(0, int.min(i, max))
}

fn get_at(list, idx) {
  case idx {
    0 ->
      case list.first(list) {
        Ok(v) -> v
        Error(_) -> panic as "Index out of bounds"
      }
    _ ->
      case list {
        [] -> panic as "Index out of bounds"
        [_, ..tail] -> get_at(tail, idx - 1)
      }
  }
}

pub fn q1p1() {
  let #(names, instrs) = parse_input(input_p1())
  let res_idx =
    list.fold(instrs, 0, fn(acc, instr) {
      let Instruction(dir, steps) = instr
      let new_idx =
        case dir {
          Left -> acc - steps
          Right -> acc + steps
        }
        |> clamp(list.length(names) - 1)
      new_idx
    })
  let name = get_at(names, res_idx)
  name
}

pub fn q1p2() {
  let #(names, instrs) = parse_input(input_p2())
  let len = list.length(names)
  let res_idx =
    list.fold(instrs, 0, fn(acc, instr) {
      let Instruction(dir, steps) = instr
      let new_idx =
        case dir {
          Left -> { acc - steps + len } % len
          Right -> { acc + steps } % len
        }
        |> clamp(list.length(names) - 1)
      new_idx
    })
  io.println("Final index: " <> int.to_string(res_idx))
  let name = get_at(names, res_idx)
  name
}

/// Swaps the elements at index 'i' with the first element in a list.
pub fn switch_first_and_idx(input_list: List(String), idx: Int) {
  // 1. Get the current length
  let len = list.length(input_list)

  // 2. Simple validation for out-of-bounds indices
  let valid_i = idx >= 0 && idx < len

  // Handle case where indices are invalid
  case valid_i {
    False -> []
    True -> {
      // 3. Extract the elements and the parts of the list
      // Note: We use the helper function list.drop and list.first to get the element at a position
      let first_element = list.first(input_list) |> result.unwrap("Empty list")
      let rest_of_list = list.drop(input_list, 1)
      let element_at_idx =
        list.drop(input_list, idx)
        |> list.first
        |> result.unwrap("Index too big.")

      // 4. Split and Reassemble the List
      let #(first_part, rest) = list.split(rest_of_list, idx - 1)
      let rest = list.drop(rest, 1)

      // Reassemble with swapped elements
      let new_list = [element_at_idx, ..first_part]
      let new_list = list.append(new_list, [first_element])
      let new_list = list.append(new_list, rest)

      new_list
    }
  }
}

pub fn q1p3() {
  let #(names, instrs) = parse_input(input_p2())
  let len = list.length(names)
  let res_idx =
    list.fold(instrs, 0, fn(acc, instr) {
      let Instruction(dir, steps) = instr
      let new_idx =
        case dir {
          Left -> { acc - steps + len } % len
          Right -> { acc + steps } % len
        }
        |> clamp(list.length(names) - 1)
      new_idx
    })
  io.println("Final index: " <> int.to_string(res_idx))
  let name = get_at(names, res_idx)
  name
}
