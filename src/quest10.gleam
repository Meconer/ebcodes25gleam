import gleam/list
import gleam/set
import gleam/string

pub fn q10p1(inp: String, no_of_steps: Int) -> Int {
  parse_input(inp)
  |> echo
  0
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
