import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import utils

pub fn part1(inp: String) {
  let piles =
    inp
    |> string.split("\n")
    |> list.map(fn(line) {
      string.to_graphemes(line)
      |> list.map(fn(g) { int.parse(g) |> result.unwrap(-1) })
    })
    |> utils.create_board()
    |> echo
  let res =
    ignite(piles, utils.Pos(0, 0), set.from_list([utils.Pos(0, 0)]))
    |> echo
  0
}

fn ignite(piles: utils.Board(Int), pos: utils.Pos, ignited: set.Set(utils.Pos)) {
  let neighbours = utils.get_neighbours_4(piles, pos)
  let this = dict.get(piles.board_el, pos) |> result.unwrap(-1)
  list.fold(neighbours, ignited, fn(i_acc, neighbour) {
    case set.contains(ignited, neighbour) {
      True -> i_acc
      False -> {
        let n_val = dict.get(piles.board_el, neighbour) |> result.unwrap(-1)
        case n_val <= this {
          True -> {
            let n_ignited = ignite(piles, neighbour, i_acc)
            set.union(n_ignited, i_acc)
          }
          False -> i_acc
        }
      }
    }
  })
}

pub const sample_input_1 = "989601
857782
746543
766789"
