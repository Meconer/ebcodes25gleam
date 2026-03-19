import gleam/dict
import gleam/int
import gleam/list

pub type Pos {
  Pos(r: Int, c: Int)
}

pub type Board(a) {
  Board(width: Int, height: Int, board_el: dict.Dict(Pos, a))
}

pub fn create_board(elements: List(List(a))) {
  let width = unsafe_list_first(elements) |> list.length()
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

pub fn unsafe_list_first(lst: List(a)) -> a {
  case lst {
    [] -> panic as "empty list"
    [first, ..] -> first
  }
}

pub fn unsafe_list_last(lst: List(a)) -> a {
  case list.last(lst) {
    Ok(el) -> el
    Error(_) -> panic as "error in unsafe_list_last"
  }
}

pub fn unsafe_int_parse(s: String) -> Int {
  case int.parse(s) {
    Ok(n) -> n
    Error(_) -> panic as "error in unsafe_int_parse"
  }
}
