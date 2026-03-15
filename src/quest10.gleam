import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/set
import gleam/string

pub fn q10p1(inp: String, no_of_steps: Int) -> Int {
  let #(sheep, dragon_row, dragon_col, _, _, _) = parse_input(inp)
  let start_point = #(dragon_row, dragon_col)
  let reachable_points =
    get_reachable_points(set.from_list([start_point]), no_of_steps)
  let reachable_sheep = set.intersection(sheep, reachable_points)
  set.size(reachable_sheep)
}

pub fn q10p2(inp: String, no_of_rounds: Int) -> Int {
  let #(sheep, dragon_row, dragon_col, hiding_spots, _, _) = parse_input(inp)
  let lines = string.split(inp, "\n")
  let max_row = list.length(lines)
  let dragon_positions = set.from_list([#(dragon_row, dragon_col)])
  do_round(sheep, dragon_positions, hiding_spots, no_of_rounds, max_row, 0)
}

fn do_round(
  sheep: set.Set(#(Int, Int)),
  dragon_positions: set.Set(#(Int, Int)),
  hiding_spots: set.Set(#(Int, Int)),
  no_of_rounds: Int,
  max_row: Int,
  no_of_eaten_sheep: Int,
) {
  case no_of_rounds {
    0 -> no_of_eaten_sheep
    _ -> {
      // Move the dragons
      let dragon_positions = do_dragon_move(dragon_positions)
      // Eat the sheep at the dragon positions if it is not a hiding spot
      let #(sheep, eat_count1) =
        eat_sheep(dragon_positions, sheep, hiding_spots)
      let sheep = do_sheep_move(sheep, max_row)
      let #(sheep, eat_count2) =
        eat_sheep(dragon_positions, sheep, hiding_spots)
      do_round(
        sheep,
        dragon_positions,
        hiding_spots,
        no_of_rounds - 1,
        max_row,
        no_of_eaten_sheep + eat_count1 + eat_count2,
      )
    }
  }
}

fn do_sheep_move(sheep: set.Set(#(Int, Int)), max_row: Int) {
  set.map(sheep, fn(s) {
    let #(row, col) = s
    #(row + 1, col)
  })
  |> set.filter(fn(s) { s.0 <= max_row })
}

fn eat_sheep(
  dragon_positions: set.Set(#(Int, Int)),
  sheep: set.Set(#(Int, Int)),
  hiding_spots: set.Set(#(Int, Int)),
) {
  // Positions where a dragon could eat a sheep
  let eat_positions = set.difference(dragon_positions, hiding_spots)
  let not_eaten_sheep = set.difference(sheep, eat_positions)
  let eaten_count = set.size(sheep) - set.size(not_eaten_sheep)
  #(not_eaten_sheep, eaten_count)
}

const dragon_deltas = [
  #(1, 2),
  #(2, 1),
  #(-1, 2),
  #(-2, 1),
  #(1, -2),
  #(2, -1),
  #(-2, -1),
  #(-1, -2),
]

fn get_reachable_points(reachables: set.Set(#(Int, Int)), no_of_steps: Int) {
  case no_of_steps {
    0 -> reachables
    _ -> {
      let new_r =
        set.fold(reachables, reachables, fn(acc, point) {
          let #(r, c) = point
          let new_points =
            list.map(dragon_deltas, fn(delta) {
              let #(dr, dc) = delta
              #(r + dr, c + dc)
            })
          set.union(acc, set.from_list(new_points))
        })
      get_reachable_points(new_r, no_of_steps - 1)
    }
  }
}

fn do_dragon_move(dragon_positions: set.Set(#(Int, Int))) {
  set.fold(dragon_positions, set.new(), fn(acc, point) {
    let #(r, c) = point
    let new_points =
      list.map(dragon_deltas, fn(delta) {
        let #(dr, dc) = delta
        #(r + dr, c + dc)
      })
    set.union(acc, set.from_list(new_points))
  })
}

fn parse_input(
  inp: String,
) -> #(set.Set(#(Int, Int)), Int, Int, set.Set(#(Int, Int)), Int, Int) {
  let height = inp |> string.split("\n") |> list.length()
  let width =
    inp
    |> string.split("\n")
    |> list.first()
    |> result.unwrap("")
    |> string.length()
  let #(sheep, dragon_row, dragon_col, hiding_spots) =
    inp
    |> string.split("\n")
    |> list.index_fold(#([], 0, 0, []), fn(outer_acc, line, line_no) {
      let line_els = string.to_graphemes(line)
      let line_items =
        list.index_fold(line_els, #([], 0, 0, []), fn(inner_acc, el, col_no) {
          let #(sheep_list, dr, dc, h_spots) = inner_acc
          case el {
            "S" -> #([#(line_no, col_no), ..sheep_list], dr, dc, h_spots)
            "#" -> #(sheep_list, dr, dc, [#(line_no, col_no), ..h_spots])
            "D" -> #(sheep_list, line_no, col_no, h_spots)
            _ -> #(sheep_list, dr, dc, h_spots)
          }
        })
      let #(all_sheep, odr, odc, ho_spots) = outer_acc
      let #(sheep, dr, dc, h_spots) = line_items
      let #(new_dr, new_dc) = case dr, dc {
        0, 0 -> #(odr, odc)
        dr, dc -> #(dr, dc)
      }
      #(
        list.append(all_sheep, list.reverse(sheep)),
        new_dr,
        new_dc,
        list.append(ho_spots, h_spots),
      )
    })
  #(
    sheep |> set.from_list(),
    dragon_row,
    dragon_col,
    hiding_spots |> set.from_list(),
    width,
    height,
  )
}

type Board {
  Board(
    width: Int,
    height: Int,
    hiding_spots: set.Set(#(Int, Int)),
    escape_spots: set.Set(#(Int, Int)),
  )
}

pub type Turn {
  Sheep
  Dragon
}

pub type State {
  State(sheep: List(#(Int, Int)), dragon_pos: #(Int, Int), turn: Turn)
}

pub fn int_pow(base: Int, exp: Int) -> Int {
  case exp {
    0 -> 1
    e if e < 0 -> 0
    // Or handle as error
    _ -> base * int_pow(base, exp - 1)
  }
}

fn state_to_key(state: State) {
  let sheep_key =
    list.fold(state.sheep, "", fn(acc, sh) {
      let #(r, c) = sh
      let key = int.to_string(r) <> "," <> int.to_string(c) <> ";"
      acc <> key
    })
  let #(dr, dc) = state.dragon_pos
  let dragon_pos_key = int.to_string(dr) <> "," <> int.to_string(dc)
  let turn_key = case state.turn {
    Sheep -> "S"
    Dragon -> "D"
  }
  sheep_key <> dragon_pos_key <> turn_key
}

fn sheep_set_to_state(sheep_set: set.Set(#(Int, Int))) {
  set.fold(sheep_set, [], fn(acc, sh) {
    let #(r, c) = sh
    [#(r, c), ..acc]
  })
  |> list.sort(fn(el1, el2) {
    let #(_, c1) = el1
    let #(_, c2) = el2
    int.compare(c1, c2)
  })
}

fn rec_find_esc_r(
  hiding_spots: set.Set(#(Int, Int)),
  acc_esc_spots: List(#(Int, Int)),
  width: Int,
  height: Int,
  row: Int,
) -> set.Set(#(Int, Int)) {
  let last_row = height - 1
  case row {
    -1 ->
      // We are above the board. Return the escape spots
      set.from_list(acc_esc_spots)
    row if row == last_row -> {
      // First case, we are on the last row so all hiding spots here are escape spots
      // Loop over the columns
      let esc_spots =
        list.range(0, width - 1)
        |> list.fold([], fn(acc, col) {
          case set.contains(hiding_spots, #(row, col)) {
            True -> [#(row, col), ..acc]
            False -> acc
          }
        })
      rec_find_esc_r(hiding_spots, esc_spots, width, height, row - 1)
    }
    r -> {
      // We are above the last row. If the spot below this is an escape spot and this is a hiding_spot then
      // this will also be an escape spot
      let esc_spots =
        list.range(0, width - 1)
        |> list.fold(acc_esc_spots, fn(acc, col) {
          case list.any(acc_esc_spots, fn(spot) { spot == #(r, col) }) {
            True -> [#(row, col), ..acc]
            False -> acc
          }
        })
      rec_find_esc_r(hiding_spots, esc_spots, width, height, r - 1)
    }
  }
}

fn find_escape_spots(
  hiding_spots: set.Set(#(Int, Int)),
  width: Int,
  height: Int,
) -> set.Set(#(Int, Int)) {
  rec_find_esc_r(hiding_spots, [], width, height, height - 1)
}

pub fn q10p3(inp: String) {
  let #(sheep, dr, dc, hiding_spots, width, height) = parse_input(inp)
  let escape_spots = find_escape_spots(hiding_spots, width, height)
  let hiding_spots = set.difference(hiding_spots, escape_spots)
  let board = Board(width, height, hiding_spots, escape_spots)
  let sheep_state = sheep_set_to_state(sheep)
  let state = State(sheep: sheep_state, dragon_pos: #(dr, dc), turn: Sheep)
  let #(cnt, _cache) = do_p3_round(state, board, dict.new())
  cnt
}

fn do_sheep_round_p3(
  state: State,
  board: Board,
  cache: dict.Dict(String, Int),
) -> #(Int, dict.Dict(String, Int)) {
  case dict.get(cache, state_to_key(state)) {
    Ok(cnt) -> #(cnt, cache)
    Error(_) -> {
      let #(count, sheep_could_move, new_cache) =
        list.fold(state.sheep, #(0, False, cache), fn(acc, sh) {
          let #(cnt, _sheep_could_move, inn_cache) = acc
          let #(r, c) = sh
          let new_r = r + 1
          case
            #(new_r, c) == state.dragon_pos
            && !set.contains(board.hiding_spots, #(new_r, c))
          {
            True ->
              // Sheep cannot move to dragon pos when it is not a hideout. Return 0 
              acc
            False ->
              case
                new_r >= board.height
                || set.contains(board.escape_spots, #(new_r, c))
              {
                True ->
                  // Sheep is leaving the board. Also return 0
                  #(cnt, True, inn_cache)
                False -> {
                  // Sheep was able to move
                  let sheep_list = [
                    #(new_r, c),
                    ..list.filter(state.sheep, fn(sh) {
                      let #(sr, sc) = sh
                      !{ sr == r && sc == c }
                    })
                  ]
                  let new_state =
                    State(sheep_list, state.dragon_pos, turn: Dragon)
                  let #(sub_cnt, new_cache) =
                    do_p3_round(new_state, board, inn_cache)
                  #(cnt + sub_cnt, True, new_cache)
                }
              }
          }
        })
      case sheep_could_move {
        True -> #(count, new_cache)
        False -> {
          // If the sheep could not move we skip it and recurse further
          let new_state = State(state.sheep, state.dragon_pos, turn: Dragon)
          let #(sub_count, new_cache) = do_p3_round(new_state, board, new_cache)
          #(count + sub_count, new_cache)
        }
      }
    }
  }
}

fn do_dragon_round_p3(
  state: State,
  board: Board,
  cache: dict.Dict(String, Int),
) -> #(Int, dict.Dict(String, Int)) {
  case dict.get(cache, state_to_key(state)) {
    Ok(cnt) -> #(cnt, cache)
    Error(_) -> {
      let #(dragon_row, dragon_col) = state.dragon_pos
      let neighbours =
        dragon_deltas
        |> list.map(fn(delta) {
          let #(dr, dc) = delta
          #(dragon_row + dr, dragon_col + dc)
        })
        |> list.filter(fn(pos) {
          let #(r, c) = pos
          r >= 0 && r < board.height && c >= 0 && c < board.width
        })
      let #(count, new_cache) =
        list.fold(neighbours, #(0, cache), fn(acc, neighbour) {
          case
            list.any(state.sheep, fn(sh) { neighbour == sh })
            && !set.contains(board.hiding_spots, neighbour)
          {
            True -> {
              // We found a sheep. Eat it
              let sheep_list =
                list.filter(state.sheep, fn(sh) { neighbour != sh })
              case list.is_empty(sheep_list) {
                True ->
                  // Last sheep is eaten, add 1 to the count
                  #(acc.0 + 1, acc.1)
                False -> {
                  // There are sheep left so we recurse
                  let curr_state = State(sheep_list, neighbour, Sheep)

                  let #(sub_cnt, new_cache) =
                    do_p3_round(curr_state, board, acc.1)
                  let #(cnt, _cache) = acc

                  #(cnt + sub_cnt, new_cache)
                }
              }
            }
            False -> {
              // No sheep on this neighbor so we continue
              let #(curr_cnt, curr_cache) = acc
              let curr_state =
                State(sheep: state.sheep, dragon_pos: neighbour, turn: Sheep)
              let #(sub_cnt, sub_cache) =
                do_p3_round(curr_state, board, curr_cache)
              #(curr_cnt + sub_cnt, sub_cache)
            }
          }
        })
      #(count, new_cache)
    }
  }
}

fn do_p3_round(
  state: State,
  board: Board,
  cache: dict.Dict(String, Int),
) -> #(Int, dict.Dict(String, Int)) {
  case dict.get(cache, state_to_key(state)) {
    Ok(cnt) -> #(cnt, cache)
    Error(_) -> {
      let #(count, next_cache) = case state.turn {
        Sheep -> {
          do_sheep_round_p3(state, board, cache)
        }
        Dragon -> {
          do_dragon_round_p3(state, board, cache)
        }
      }
      #(count, dict.insert(next_cache, state_to_key(state), count))
    }
  }
}

pub const sample_input_1 = "...SSS.......
.S......S.SS.
..S....S...S.
..........SS.
..SSSS...S...
.....SS..S..S
SS....D.S....
S.S..S..S....
....S.......S
.SSS..SS.....
.........S...
.......S....S
SS.....S..S.."

pub const sample_input_2 = "...SSS##.....
.S#.##..S#SS.
..S.##.S#..S.
.#..#S##..SS.
..SSSS.#.S.#.
.##..SS.#S.#S
SS##.#D.S.#..
S.S..S..S###.
.##.S#.#....S
.SSS.#SS..##.
..#.##...S##.
.#...#.S#...S
SS...#.S.#S.."

pub const sample_input_3 = "SSS
..#
#.#
#D."

pub const sample_input_4 = "SSS
..#
..#
.##
.D#"

pub const sample_input_5 = "..S..
.....
..#..
.....
..D.."

pub const sample_input_6 = ".SS.S
#...#
...#.
##..#
.####
##D.#"

pub const sample_input_7 = "SSS.S
.....
#.#.#
.#.#.
#.D.#"

pub const q10_input_1 = ".SSSSS.SSSSSS.SS.S.SS
S.SS.SSSS.SSS.SS.S.SS
.SSSS.S.SSSSSSSSS....
SSS.SSSSSSSS.SSSSSSSS
SSSSSSSSSSS.S.SSSSSSS
S.SSSSS.SS.SSSSSS.S.S
SS...SSSSSS.SSSSSSSSS
SSS...SSS.S.SS.SS.SSS
SS.SSSS.SSSSS.S.S.S..
SSSS.SSSS.S.SSSSSS.SS
.SSSS..SS.DSSSSSSS..S
SSS..S.SSSSS.SSS..S..
SSS.SSSSSSSSSS.SSSSSS
SSSSS.SSSS..SS.SSSSSS
.SSSS.SSSS..SSSS..S..
S.SSS.SSSSSSSSSS..SS.
S.SSS.SSSSSSS.SS.S.S.
.SS...SSSSSSSS.SS..SS
.S.S.SS.SS.SSSSSSS..S
.S.S.SS.SSS.S..SSS.S.
SSSS.SS..SSSSS.SS..SS"

pub const q10_input_2 = "##..S#.#.SS.....SS.....#S..#...#.#..S#S...SSS#SSSS.##.SS#.S#.SS#SSS#.#S.S...S.S..#.S##S.S#..S.SS...S.
S..S##S#S#.#..#.##SS..#...S.SSSSSS####S.##SSS.....#S###S..S#S#.S#SSS.S.SS....S.SSS..SSSS....##.#S.S..
.S####SS.#.SS#S.S##..S.SS#.S.###...#....#SS.#SS..S######S..#.S#..SS.S.S.S#S#SSS.S.#SSSS.S.S#.SS....S.
S.S##S..SSS#S.S.S...SS.#...SS..S.....S.##SSS..S.SSS#...#...SSS..S....#.S.SS..S#S##.....S#SS.S....#S#.
.#SS#.#S.....S.#S##S..S#S.S.#...S..SSS#S.#.#.#S..#..S.S..S..S#SS.#S.SS.#.....S..#.#..SS.#S##.SS#..S..
.SS...S..S..##S#..#SSS##.SS..S.S.#SS..#SS..##.#.#S.SSS...S....S#S.##SS#..S..#.S..SSSS.SS..S#S......SS
#S#SSSS..S...SS.....#SS#S###.#...S.#S#SS..S..SS.#.S#S.SS.SS#..S.S.S.....#.S.SSSS.#.#S#SS#...S...#.S.S
.#S...S..SSS...S#...##S.S..#.SS.SS#S#.SSS.S.SS.S.#SSSS.SS.SS.S.#SS..#SS..S...S.S.S##S.S....#...S.#...
...S.S....SS#S..#...SS.#.#S#.SS#..SS.S.###.#.S#.S...#..SS.###S.SS#.##.....#S..##.#.##S..#...S.#.S###S
...S.#.#.S...S.SSS.SSSS...SS.S..#.####..#SSS..#...S.S#S#SS..###..#S#SS....SS.S#.S#.S#..#SSS#S..####SS
...#......S.S###S.#..S###S.#....#..#.#.....#.S..#...SS.S#S..SSSS.....#S..#S...#.#.S.#.#S#.S.S.S#..#..
.SS.SS.S...S..#.S.S.SS.S....##..S.##S#.SSS#.S##S.S.##.#.#S##...S#.SSS..SS..SS#S.#.S.S.S.S.SS#SS.SS.S.
S..S.SS.#S#..S.##S.SSSS.#.#.#.S..S##.SS..S#.#S#SSS#.SS..#.S##.S.S...S.#.#SS.SS...#S..S......#SS#SS#.#
SS..##.SS#.#.S##.S#S...S...#..SSS.S.SS.S.#SS.#...S.S###S.S..#S..S.S..S.S.#..#S##.#S..S.###S...#.#.#S.
.S....##...S.#..S#.S.S#SSS.....S.SS.SS#.#S...S##S..SSSS#S..#SSS#.#S..S..SSS.S#SS##S#S#S.#..#S...S.###
S#.S.S##S..#.SS.S#..SS#.S.S..S..###.S#S..SS...SSS#......S..SSS..SS...S.SS#..S#.S#...S.#S....S..S#.S.S
.#.S..#.#.S#S.#.SSSS.#.S..##.S..SS....#..SSS#S....S..S#.SS#.#S.SSS.S##S#.SSSSS.SSS...S#S.#..###...S..
SS...#S##S#S.SS#.SSS#SSSS...S.#S.###.#SSS.S.SS#SSS...S#S.SS##SSS#S...#....S...S....S..#.S#.........S.
S.SS#..SSS..#.#.SS.S#S.......S...S.S.#S#S#...SS..#S...#S..#SS....S..#..#..SS#.#.S..#..###.#S.#S...#S#
.S..........##.SS#SSS#S##.SSSSS#..#S...#.....S.##..##S.S.S.#S#S.S#..SSS#..S#S...#S#S......S..S.#S.S..
.S...SSSSSS#S.SS.#..S...SS.#S###.#...#.S#S.S..........#..#S.###.###S.SS#S.#S.S#S.#.S###S#S.....S.#...
SSS#SSS#..S...S.SSSS..S..SS#..S..S....#..#.S#S.....S..S...S#S.S...S.#S.##S#S.S..S.S.....S.#S..S#.#..#
#S#.S...S#S#.SS...SS#S.#.S..S.#..##SS#.S##S.SS.SS.#.S#.#.#.S.S###.#.SSS#S.#S......##SS.####.S.SSS##S.
S.#.S...#S##SSS.......SSS..S#S....S.S#S.#.#SSS.#SSS..#.S#S#SSS...S...S..S#.....SSSSS#SS#S#..........S
#.#S#####S....S#SS.SS#.S#.S...S.S.S#.SS..S.SS.S.#S#S#.#S.#.S.##....S#SSSS#.S.##.#S.S..S#.SS.S#S..SSS.
..##..SS#.#.SS#S.S.SS..#S.#S.S.S...#.S.S##S.S.#SS..SSSS#SS.#S.#S#SS##...#.S##...#..#S#.#S#SS.....S.##
..S#SS.S..SS.##..#..S..SSS.#S.S..S....##..S#S#.##SS.#S..#SS#S##.#.#S.S#S.#S#..S##....SS..###SS.S...#.
..S##.S#.#S#S.S##....#S...##.#..S##..##..#.S.#.S.#.##.SS#..#.S..#SSSS.#..SSSSSS.SS.S#.##S..SSS..S#...
S##...SS#S.S..##....S#...#SSSS..SSSS.SS.#..S##....#SS..S.#.SS.#..#..#S#SSSS.S..S..S.#S#S##.S...SS..##
.S..#S#S.S..##.#..#.S.#S.SS........#.....SS..S..........S..#....#.##......S#.S.##.#S.....###.SSS..S.#
....##S.##..S...S#........S...S...S.SSS..S..S#...#..S..#S.S.#S...#SS#...#..S.#S.#.##S.S..#.#.S.#...S.
##.SS#.##SSSS##..#S#.#SS##..#...S#.SS#.SS.#......##.S#.S..S.#S.S..#S#..SSSS.#...S###.##.S.###S.#....S
....#..S.S#SS.###..S#SSSSS.SS......#S.SS......S.###.##SSS...S....S.#S.SS.SS.#...SSS.SS##..#.S.#..S...
#S.#S.##.S..S....#S##S.S..#..####.....S.#...S#....#S.S#####S..###..SSS.#..SS##S#.##..S#.##.S..S#..SS.
S..#.##.#.S..S.##.S..SS.S..S..##..S..SS#..#SS....S#..#..SS.#..##S.S#SSS#SS.SS.S.S....S#.S..#..S.S.SS.
.#.S.S#.#..#S..SS.S#.....S...#.#S##.#S....SS....#S.SS#..SS...SS#..S.S...S#..S..#.#.#SS.S.....#S#.#S.#
S.#.S#.#S..S#...SS..SS.#.#S.S..S.#..S.##SS#S#.#.#..#S.S#S#......S...##SS.S.SS.SS.SS.S.S.#.....S#S..S.
.SS..S.#S.....##..S....#S#.S.SSSS...SS#...#SS#.SS#S.#S.##S..SS.S#SSS..#S.S.#..#SSS.#.#S.S.SSSS###.#.#
..S.##.S#.###SSS...#SS.S.SSSS..S.#S#.#.S#.S...#.S..####...S#.#.#SSS.S.#S.SS.....SS..#.#.SS..#..SS...S
.#..S...##.##..#S..#S..S#......#.SS#SS..#S.#...S.....S#S..##SSS.S.S.#S..SS...#.S..#....#S.SS.S#..SS#S
##S#SS.SS..S#.S.#.SS##..##.#S#.S..##.S.#S#S.##.#.S..##.SS#S.S#S#.#S.SSS..S#.SS.SSSS#....S.S.#SSS#....
.S.SS#..S...SSS.S#..S#...SS#SSSSSS#.#..SS##..SS..S.S#.##..S.SSSSS.S#.SS...S..#.#..S...S..S##.SSSSSS#S
S###.#.#.S.#..#.#SSS....#...#S#S#.S.S.S##.#.#S.S.#SS.S.#.S.###.####S#.SS#.SS#SSS##S.S#S..#....S.#..SS
.##S..#.SS..S..S#...S#S##S.S#.S#####..#S#S.S...S.#S##.S.S.S###...S..S..#.#S#..S..SS..S..SS.....SS...S
#.S##.S#S#SSSS#....S....S..SS....#S.S..#S...SSS.#S.#.#SS........#.S.#S..S#.#.S..S..#S.#.##...###.#SS.
.S.S..####...S#S.SS##.....SS#S##S.S.....SS#.S##.#....SSS..SS.#S##S...#.#.S..S...#.S#...#SS.S...##..SS
SS....#S#S###.S.S.SS##SS..#S...#.S.SS...#..SS##S#S#.S#..SS.S...###S#S.#SS..#.#SS........S.S#.SSSS#.S#
SS..S.#.#S.S#S#S#SS....#.S#S#.SS.#..S.S..S.S.#S#.S.#S.SS...S.#S.S###.....#S##.S#.#S##S##S..#..S##S#.#
.#.#..#S.S..#...##.#SS##SS.SSS..S.#.#S.##SSSSSS##S.#S.#SSS.#..SS#.#.S#S#S#.SS..SS#S.SS..#S#S..SS#S.#.
.S####.S#S..S#......#SS#..S.#....S.S##S.S.SSSSSSSS#S.S#SS#..S.##..S.#..#.S#S#S.S....S..S.#.#.SS#.S#.#
.S...S#.S..###S#.#SS.#.S..S.S#.....S.#S.#S..#SS.#SDS#.S#.S.S.#S#..#.....###..#..S..SS...S.#.##.S.#...
S.#.#SS#.S..S..#..SS...##S##.#S#..SSS#.#.S....S.....S##..S#..#SS.S#.S#.....#SS.S.S.S....S.SSS#S..#SS#
#.....S...#SS.S.#...#SSS.#.#S.S#S.SSS..#.#..SSSSS.SS#....##..#S....SSSS##S..SSSS..SS#..#..#....S.S..#
S.#.S..#.S.S.......S.#..S.....#S.S#SS#.#....S.....S...#SS.#SS..##S......#S...#S.##.....SS.####SSS.S..
#SSS#......SS.##.SS..###..S.S.S##..#.S...SS#.#S.S.S..#.S#S##..S#S#..S.SS#.#S#....###S.#.S#S.#.#..#S.#
SSS.SS#SS...#S..#..S#S#S.S.#S.S.....S##.#S....S..SS.SS#SSS#..S..##.#S.SS..S##SSS.#.SS.#.SSS..S#.#SS##
....##.S..S..S#......S##.SS#S....SS#S.SSS.S.S#.S.S..S#S.S....#.SSS.#.....SS..#.S#S#.#..SS.#S##.#...#S
.SS..SS...##.#.SS.S.......#SS..S#SS.S.###..S..SSS#SS....S.#.S.S..#S####.#.S..S.SS.S.S..SS...SSS##S##.
S##.S.S.SSSS####..#S...#SS..SS#SS.S....SSS#.....SS...S#.#SS.S#.#...S.#S..#.S....##.#.#S.#...SS..#.SSS
S..SSS#S#S.#.##.S#.S.S...S...S#SS#SS#S..S#.S#.S.S..SS..#S.S#...#####.S.#S##..S.S.#.S#.S.SSS#S.#S#....
.S#####S..S#.SS.#..SS..#.S.S.S..#.S...S#S#SSS#S.SSSSS.S#.SS....#S....S#S.SS..SS#..SSS#.#S...SS.#.S..S
.##.#.S..#S##.S.SS###SS#SS##SSS.S.SS...##SSSS.....#.##SS.#SSS.S.......S..#.S..SSS....S#.#S..##S..SS..
....SS#.....#S...##S.S...#....##.S.S.SS...S.....S.###S#...S#.S#SS..S#S.#.###.#S#..S...#......#.#..#S.
..S##.S.S.SS#SS#SS.#SS#SSS..#....S..#S#..#S#.SS.#S#..#.#..#SS###S.##.#S.#SS..SS..S.#S..SS#..#SSSS....
.....#SS#S..SS.#SS..S#..S#.S#SS.#.SS.#..S#S#.#.##.S#.....SSS#SS.S#..S#..#..SSS..S.SS.........##SS...#
##...S.S#S..SS#..S.S..##SS.S..#.#.S.#.#..###.#SS.##.S..S..S.#S#S##....#SS#S.S.#.#.S..S.S.#S#S#.#.S...
S.#SS....#S#.S....SS.S..###....S.S#SS......SS###S.#S.S.###.SS...SSSSSS#...#..#..S...#SS.#..SSS#..S...
..S...##..S##..S..##S#.###S#S.SS.SSS.SS....#SSS.###.##...#SS.#.#.SS#SS#..S.S.SS..#SSS#.#.S..S...SSS..
.S.S##..S###.SS.#..#S#S##.S...S....S##S..#S##.S...#S..#....SSS.SS..S...SS..#S.#S.SS...#S..S....#...##
SS.##.#SS.##S#SS.S#.#..SS.#..#.SS#SSS....S.#.SSSSS.SS..#S..#...SSSSS....#S...#.#S..SS.S.SS......S.SS.
SS.#SS..S##S.S#S#SSS..#S.#..#.##..S##SSSS.SS#..#S..##.#S.#S.#..#.#S#S..#....S##S#S#S#SS#.SS..#S#SS.S.
...SS...S..S#SS....#..S.#SSS........#..S.#.#.S#.S..#S....SS#S#.S..##.#SS.S#......#.SSSS.SS.S##.S.S..S
..S...#..S..S#..SS.#SS.#.SSSS#SSS##S.S.#..S...#.#..#SSS..S#.SSSS...SSS....##..#....SS.#S#.#.S.......#
......#..SSS....S#.SS..S#S#..#.S#S.#.#SS#..S...#..#S#S.......SSS..#SS#SS##S##SS..#...##..##...#.SS.#.
S##..S#..#S#.S.#.S..S.SS.####..S#.##.S..SS.SSSS#.#.......SS...###.S#S.S.S#..#S..S.S#.S.......#.#.#...
.#S..S.S....#.SS#S..S#S.S##..S..#S..#S.#SS.S#..S...#.#S#.S.#.SS#S#.S#.S##..S...S....#S#.SSSS#S..SSS..
S.##SS#...#..S#....SSS#SS###.#.##..#.SSS.#.SSS..#...#.#S....#.S...#..S.S#.S..S#..#..S..##..S.SS#S..#S
..SS#S###...SS##....#.SS#S.S.#.S.S.###SS#.SSS#.S.S..#S.S#...SS..SS.SS.S##........#.##...S#.S..##..S.S
S##S.#SSS..S...#.#.SSSS##SSS#S....S.S###.#.S.#...S.S..SS..S.S#.#.#.#SS....S..S#.#S.S#S#..#.S..##..#.#
S.S..SS...#SS#SSS..#S#..S###..SS##S..S...SSSSSSS....SS#S##.#..SSSS.S###...S......S#SS.#.#..#.S#.SSS#.
SSS#.#.S..SS#......SSSSS#SSSS..#SSSS.S#.#S..S..S.S#.##S.##.#SS.#.#S#S#S.###S.S##..SSS###S..#SSSS.....
#S.S.SS..SS.S#..#S..SSS.....#S#.SSS#.S##.S...SS#S.S..SS##.....#S.#.#......SS#.SS##..#SSSS..#...#S#SS.
SS.##S..#S..S#S###..S#S#..S.#S..#..S#.S..SSS.....#S.SS#..#SS.S.S.##....#.S....SSS#.#.S.#.#.....SS..SS
S...S..#..........##S...SSSS......S.###..S#.SSS..##SS..#S...#S.###.S.#.#S.S..S.SS..S.#.S..#SSS..S..S.
.#SS#SS.S##S#...SS#S.S##SS.#SS.#S#SSS.S...###SSS.#.S##..#S..S.S.#.S.#......S#.###SSS##S#...SS#SS..#S#
.S.S#..S#.#.SS..S....S.#S..S.#S.S.S.S##..S##S.#.#S.#.S.S.S#.SSS##S...#.S#S##S......SSS....#S.S....#S#
S..S#.S#SSS..S.S.#.SSSS.#.#SS#S.S...S.#....SSSS#S..S..#.SS....SS##.S..S.S.SS.SSS...S.S..#SS.S...S.SS.
#.SS#.SS.S.SS##SSSSSS......SS#SS#.SS.S.SS..SS..S.SSS.S.S.S.S.S..SS##S.S.SS##...S#...S..#S..S....SS#..
.S.SS#.#..S.S.#.S.S.#.SS.S.S.SS.#..SSS..#S###.SS###.S#..SSS...S...#.SS#S##S#S.SS#.#....#SS#S.SS#SS..S
#S.S...#S###SSS..##.S..#..S.SS..#...S#SSSS.S##....#.#..S.SS#...#....S#S##..S.S#S..SSS..#SS##..#.SS.SS
.S...#S..#..#S##SS...S#.#..#S.#.S....SS.S.#SS#..S..##S##S..SSSS.##.S..#...S.S#.#.#S####SSS.S#S.SS..#S
S.##...#S#S#S..#.SS#SSSS.SS##.##...SSSS...SS.#S.S.S#.###.#...S#SS#SS#.#SSS.SS#####..S#S#S#S.##..S..S#
#S.##S#.SS#.SS...S...#.SSS.SS#.S#.#.#.S.SS.SSS#.S#...S##.SS..#S.#..#.SS#S#.SS.S.SS#.S.S.SS.S#S.S.SS#S
.#S.##.S#.S#S.##..SS.SSS.S..SS...S..S#S#..S#S.#....S..S#..#.###S#.#.#.SS..SS.S.####.SS..##.#SS..SSS.#
.SSS..S#SSSS.#S#S.#S#...#..#..#S..S#SS.S..SS...##S#SSS##.S..S.....S.#..S.##...#.SS.S##.#..SS..S.##.SS
.SS##.##.SSSS#S.S.SS.S..#SS#SSSS.#S.SSSSSSS##S...S###SSSSSSS#S.SSS##S.......#S.#..S...S#SSS#S#.#.SSS.
SS..SS#....S...S##.S..#.#.#.##S..SS.#S#...S#SSS#.##..#.##S.#S#SS.#S.#SS.S.....SS.S#.S..S.S#.#.S.##..S
#..S.#.S.S..SS.S#.S.S.#S.#S.#SS.##....SS.##....S..#.S#..SS#S#S.S#...SS...#S#S.S.##.SS#.S..SSSS.S.S#S.
.S#.S.SSS#.#..#SS.SS#..####.......#S...#.#..#..#SS.#...#..SS..SSS..#.SSS...##..SS##.SSSS..S....S..S..
.SS#...#.#S.....S...SS...#.#S#S...S.S.SS..S#...S#S.SS.#.S.SS#S.SSS.#.#S..S.S###......S.#.....S#...S..
S..S..SS.SS.##.#..S.SSS#.#S.##S.##S.#.##...S...SS#.....#..S#.S.#.#S#S.##S.S...S..S###S....#SS.....S#S"

pub const q10_input_3 = "..SSSSS
.......
..#..#.
##.#.#.
###.###
###D###"
