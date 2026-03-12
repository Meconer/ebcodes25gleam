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
  Board(width: Int, height: Int)
}

type Turn {
  Sheep
  Dragon
}

type State {
  State(sheep: set.Set(#(Int, Int)), dragon_pos: #(Int, Int), turn: Turn)
}

pub fn q10p3(inp: String) {
  let #(sheep, dr, dc, hiding_spots, width, height) = parse_input(inp)
  let board = Board(width, height)
  let state =
    State(sheep: sheep, dragon_pos: #(dr, dc), turn: Sheep)
    |> echo
  do_p3_round(state, board)
  0
}

fn do_dragon_round_p3(state: State, board: Board) {
  let neighbours =
    dragon_deltas
    |> list.map(fn(delta) {
      #(state.dragon_pos.0 + delta.0, state.dragon_pos.1 + delta.1)
    })
    |> list.filter(fn(pos) {
      let #(r, c) = pos
      r >= 0 && r < board.width && c >= 0 && c < board.height
    })
  0
}

fn do_p3_round(state: State, board: Board) {
  case state.turn {
    Sheep -> {
      todo
      // do_sheep_round_p3(state)
    }
    Dragon -> {
      do_dragon_round_p3(state, board)
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
