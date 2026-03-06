import gleam/list
import gleam/set
import gleam/string

pub fn q10p1(inp: String, no_of_steps: Int) -> Int {
  let #(sheep, dragon_row, dragon_col) =
    parse_input(inp)
    |> echo
  let start_point = #(dragon_row, dragon_col)
  let reachable_points =
    get_reachable_points(set.from_list([start_point]), no_of_steps)
  let reachable_sheep =
    set.intersection(sheep, reachable_points)
    |> echo
  0
}

fn get_reachable_points(reachables: set.Set(#(Int, Int)), no_of_steps: Int) {
  case no_of_steps {
    0 -> reachables
    _ -> {
      let deltas = [
        #(1, 2),
        #(2, 1),
        #(-1, 2),
        #(-2, 1),
        #(1, -2),
        #(2, -1),
        #(-2, -1),
        #(-1, -2),
      ]
      let new_r =
        set.fold(reachables, reachables, fn(acc, point) {
          let #(r, c) = point
          let new_points =
            list.map(deltas, fn(delta) {
              let #(dr, dc) = delta
              #(r + dr, c + dc)
            })
          set.union(acc, set.from_list(new_points))
        })
      get_reachable_points(new_r, no_of_steps - 1)
    }
  }
}

fn parse_input(inp: String) {
  let #(sheep, dragon_row, dragon_col) =
    inp
    |> string.split("\n")
    |> list.index_fold(#([], 0, 0), fn(outer_acc, line, line_no) {
      let line_els = string.to_graphemes(line)
      let line_items =
        list.index_fold(line_els, #([], 0, 0), fn(inner_acc, el, col_no) {
          let #(sheep_list, dr, dc) = inner_acc
          case el {
            "S" -> #([#(line_no, col_no), ..sheep_list], dr, dc)
            "D" -> #(sheep_list, line_no, col_no)
            _ -> #(sheep_list, dr, dc)
          }
        })
      let #(all_sheep, odr, odc) = outer_acc
      let #(sheep, dr, dc) = line_items
      let #(new_dr, new_dc) = case dr, dc {
        0, 0 -> #(odr, odc)
        dr, dc -> #(dr, dc)
      }
      #(list.append(all_sheep, list.reverse(sheep)), new_dr, new_dc)
    })
  #(sheep |> set.from_list, dragon_row, dragon_col)
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
