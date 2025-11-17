import gleam/int
import gleam/list
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

fn get_input() {
  let input =
    "Vyrdax,Drakzyph,Fyrryn,Elarzris

R3,L2,R3,L1"
    |> string.split("\n\n")
  let #(namesstr, instrsstr) = case input {
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

pub fn q1p1() {
  let #(names, instrs) = get_input()
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
  res_idx
}
