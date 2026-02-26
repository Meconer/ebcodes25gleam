import gleam/dict
import gleam/list
import gleam/set
import gleam/string
import utils

pub const sample_input_1 = "1:CAAGCGCTAAGTTCGCTGGATGTGTGCCCGCG
2:CTTGAATTGGGCCGTTTACCTGGTTTAACCAT
3:CTAGCGCTGAGCTGGCTGCCTGGTTGACCGCG"

pub fn q9p1(inp: String) {
  let dragon_ducks =
    inp
    |> string.split("\n")
    |> echo
    |> list.map(fn(line) {
      let parts = string.split(line, ":")
      let number =
        utils.unsafe_list_first(parts)
        |> utils.unsafe_int_parse()
      let dna = utils.unsafe_list_last(parts) |> string.to_graphemes()
      #(number, dna)
    })
    |> dict.from_list()
    |> echo
  let child = get_child(dragon_ducks)
  0
}

fn get_child(dragon_ducks: dict.Dict(Int, List(String))) -> Int {
  let possible_childs = set.from_list([1, 2, 3])
  0
}
