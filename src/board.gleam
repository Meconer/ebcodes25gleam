import gleam/dict
import gleam/list
import utils

pub type Pos {
  Pos(r: Int, c: Int)
}

pub type Board(a) {
  Board(width: Int, height: Int, board_el: dict.Dict(Pos, a))
}

pub fn create_board(elements: List(List(a))) {
  let width = utils.unsafe_list_first(elements) |> list.length()
  let height = list.length(elements)
  let rows =
    list.index_map(elements, fn(row, row_idx) {
      list.index_map(row, fn(el, col_idx) { #(Pos(row_idx, col_idx), el) })
    })
    |> list.flatten()
  Board(width, height, dict.from_list(rows))
}

pub fn get_neighbours_4(board: Board(a), pos: Pos) {
  let deltas = [
    #(0, -1),
    #(0, 1),
    #(-1, 0),
    #(1, 0),
  ]
  list.fold(deltas, [], fn(acc, delta) {
    let #(dr, dc) = delta
    let nr = dr + pos.r
    let nc = dc + pos.c
    case nr >= 0 && nr < board.height {
      True -> {
        case nc >= 0 && nc < board.width {
          True -> [Pos(nr, nc), ..acc]
          False -> acc
        }
      }
      False -> acc
    }
  })
}
