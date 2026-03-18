import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn part1(inp: String) {
  let piles =
    inp
    |> string.split("\n")
    |> list.index_map(fn(line, row_idx) {
      #(
        row_idx,
        string.to_graphemes(line)
          |> list.index_map(fn(g, idx) {
            #(idx, int.parse(g) |> result.unwrap(-1))
          })
          |> dict.from_list(),
      )
    })
    |> dict.from_list()
    |> echo

  0
}

fn get_pile(piles: dict.Dict(Int, dict.Dict(Int, Int)), row: Int, col: Int) {
  use dct <- result.try(dict.get(piles, row))
  use pile <- result.try(dict.get(dct, col))
  Ok(pile)
}

pub const sample_input_1 = "989601
857782
746543
766789"
