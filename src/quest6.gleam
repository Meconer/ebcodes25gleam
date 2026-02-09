import gleam/list
import gleam/string

fn get_sword_fight(inp) {
  string.replace(inp, "B", "")
  |> string.replace("b", "")
  |> string.replace("C", "")
  |> string.replace("c", "")
}

pub fn q6p1(inp) {
  let sword_fighters =
    inp
    |> get_sword_fight()
    |> string.to_graphemes()
    |> list.reverse()
  count_mentors(sword_fighters, "a", 0)
}

fn get_category(s: String, category: String) -> List(String) {
  s
  |> string.to_graphemes()
  |> list.filter(fn(el) {
    el == string.lowercase(category) || el == string.uppercase(category)
  })
  |> list.reverse()
}

pub fn q6p2(inp) {
  let sword_fighters = get_category(inp, "a")
  let archers = get_category(inp, "b")
  let magicians = get_category(inp, "c")
  count_mentors(sword_fighters, "a", 0)
  + count_mentors(archers, "b", 0)
  + count_mentors(magicians, "c", 0)
}

fn count_mentors(inp: List(String), category: String, acc: Int) -> Int {
  let lower = string.lowercase(category)
  let upper = string.uppercase(category)
  case inp {
    [l, ..tail] if l == lower -> {
      let ment_count = list.count(tail, fn(el) { el == upper })
      count_mentors(tail, category, acc + ment_count)
    }
    [u, ..tail] if u == upper -> count_mentors(tail, category, acc)
    [] -> acc
    [_, ..] -> panic as "Not correct category"
  }
}

pub fn sample_input_p1() {
  "ABabACacBCbca"
}

pub fn input_p1() {
  "ABCaBBCAACbACaCbaAAbcbaCbbbcbcACBcBCbCaCCccaBCccCBCcbaaBBcAAABaBbcAAAaBbABBCBBaBCAAaaBbBbbBaAACaAaab"
}

pub fn input_p2() {
  "ABCBCbACCbCcCbbACacaBCbbBcBAAACcAcCAcBBCaaAbACcbccAabABABAaBABAAAAAaacbabbcbCCAaacCAAaaBCbCCbbaBcacaaCcCCABacAbbbacbaacABcAAaABACACccaaBaBBcaAABbAacbBbccCbCBBcaCBACCBAAAbcCacaAAcCcbaAbCabaCCACCBbAAACBaaCCBcabBCAcBCbABbACaCABBbBcCbaAcbcacAAcCaACcaaAbBccacbAaBbaCaABACBbbbCABaBBbCBbABccACCAcaAAbCCaCcbc"
}
