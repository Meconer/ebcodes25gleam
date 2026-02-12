import gleam/dict
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

fn get_pers(tents: dict.Dict(Int, a), idx: Int, repeat: Int) -> Result(a, Nil) {
  let tot_length = dict.size(tents) * repeat
  echo tot_length
  echo idx
  echo repeat
  case idx {
    idx if idx < 0 -> Error(Nil)
    idx if idx >= tot_length -> Error(Nil)
    idx -> {
      let mod_idx = idx % dict.size(tents)
      let tent = dict.get(tents, mod_idx)
      tent
    }
  }
}

pub fn q6p3(inp: String, dist_lim: Int, repeat: Int) {
  let len = string.length(inp)
  let tents_lst = string.to_graphemes(inp)
  let tents =
    list.index_map(tents_lst, fn(el, idx) { #(idx, el) })
    |> dict.from_list()

  echo "---"
  let first_start = 0
  let first_end = len - 1
  let second_start = len
  let second_end = len + { repeat * len } - 1
  let last_end = len * repeat - 1
  let last_start = last_end - len + 1
  echo first_end
  echo second_start
  echo second_end
  echo last_start
  echo last_end

  let first_part_cnt =
    list.range(first_start, first_end)
    |> list.fold(0, fn(acc, key) {
      acc + count_mentors_p3(tents, repeat, dist_lim, key)
    })
    |> echo
  let last_part_cnt =
    list.range(second_start, second_end)
    |> list.fold(0, fn(acc, key) {
      acc + count_mentors_p3(tents, repeat, dist_lim, key)
    })
    |> echo
  let middle_part_cnt =
    list.range(last_start, last_end)
    |> list.fold(0, fn(acc, key) {
      acc + count_mentors_p3(tents, repeat, dist_lim, key)
    })
    |> echo
  case repeat {
    _repeat if repeat > 2 ->
      first_part_cnt + last_part_cnt + middle_part_cnt * { repeat - 2 }
    _repeat if repeat == 1 -> first_part_cnt + last_part_cnt
    _repeat -> first_part_cnt
  }
}

fn count_mentors_p3(
  tents: dict.Dict(Int, String),
  repeat: Int,
  dist_lim: Int,
  key: Int,
) -> Int {
  let assert Ok(novice) = get_pers(tents, key, repeat)
  case list.contains(["a", "b", "c"], novice) {
    False ->
      //Not a novice
      0
    True -> {
      let mentor = string.uppercase(novice)
      list.range(1, dist_lim)
      |> list.map(fn(delta) {
        let pers_before = get_pers(tents, key - delta, repeat)

        let pers_after = get_pers(tents, key + delta, repeat)
        let count =
          is_mentor_cnt(pers_before, mentor) + is_mentor_cnt(pers_after, mentor)
        count
      })
      |> list.fold(0, fn(acc, el) { el + acc })
    }
  }
}

fn is_mentor_cnt(person: Result(String, Nil), mentor: String) -> Int {
  case person {
    Ok(pers) -> {
      case pers == mentor {
        True -> 1
        False -> 0
      }
    }
    Error(_) -> 0
  }
}

pub fn sample_input_p1() {
  "ABabACacBCbca"
}

pub const sample_input_p3 = "AABCBABCABCabcabcABCCBAACBCa"

pub fn input_p1() {
  "ABCaBBCAACbACaCbaAAbcbaCbbbcbcACBcBCbCaCCccaBCccCBCcbaaBBcAAABaBbcAAAaBbABBCBBaBCAAaaBbBbbBaAACaAaab"
}

pub fn input_p2() {
  "ABCBCbACCbCcCbbACacaBCbbBcBAAACcAcCAcBBCaaAbACcbccAabABABAaBABAAAAAaacbabbcbCCAaacCAAaaBCbCCbbaBcacaaCcCCABacAbbbacbaacABcAAaABACACccaaBaBBcaAABbAacbBbccCbCBBcaCBACCBAAAbcCacaAAcCcbaAbCabaCCACCBbAAACBaaCCBcabBCAcBCbABbACaCABBbBcCbaAcbcacAAcCaACcaaAbBccacbAaBbaCaABACBbbbCABaBBbCBbABccACCAcaAAbCCaCcbc"
}

pub const input_p3 = "BcCaBACBCcAcAcBCABCBBCcabcaCcAAAacbbaaCCaaAAcCCBcabAcACCCcBAACBBAAACBbabbbBAAAcBBAacCBCcbBAcCCAcCacaBBBabacaCCcBcbbaAAAaAACAABaccCbBbCBcAaACABbbaaBbAAaCbcBBCAbBbbaACbcbAbbacabaaACbbCbbCBbcAacCAacBbBBbBAabaCAbAbBcaACaBbBcBCcBBbbBBBCBcCAcACAcAAbACbccBbcacBcBACCcACBBcbaAcBbaacABBaACBabAacABacAcCbabaAacabbBBBacCcBcaaBABbBaccbbBABcAaBCbCbBBccAbBBCAAAaBCcbBcCaaaAcAACaCBbCcacbACbCAcBCaaAbcCcACBCCBCcAaBbcABBccbAAbBABbcaAAAABBaaAacCAaBBBcbbcaccbCBAaABaCaBbCCAcaBcbBCCBBccCaACABCCcCaCabccaCBAbcCCcAaAcABbabbBAbBCcabCAAaBaBCCcbACaaaAAaaACBaCAbACBcacabABCACbBAbbCccBBaBbCBAbccacbbCaCccaACBacCBabBBAbaaAbAaAaCAAcBaCCbACacAAcbbbBAcaabAabBAaBCbAaACAacBabBAaAAaBcCBcaAcaBbcCCCAaBBAcbCcCabAbBBCCAAACbAabbaBbbCABBcAcacCBabcBbBBCCbABCbcBCAaaaBCCCbAcbaccaAcBABbcCAbACcBCCbBCCABCBCBbaAabbBACCAAbcaBbAcCcCaCbbCaBaaccbaacACBaBAAabbcBbcBCbbbcacCCccaCcbbAcACBcbcCcABBBCBCAAbCAABbcBCAAbbCBCcbBCBAaCaacaBCBaacBaCaaAacCBAbccAaBBAccBbBcABbcacAccaaaCCcbCACaAaCccBbbAbCBCABBACBBabCaaaACbbacCacAbbBCaBbcbCaACAcAbCAAcBbccBaAAACABaaaaCBcAaCCcBabcAbcbAbcbacABcBbacccabAbbbCbcbabCBacBCCBbbACbccabccacCccACbaaAaCaCBcCBbCCAabcACCCcCcBCBBbabBbAaBaBBcabCAAAAAbaBaAcacbbAaacCbCABBAaCAcbCbCbabCBAacbAbbaCBacabcacCBAcAaAAcBbcBAAbbababcbccBbBcAbCaBBaaBCBCBCcbBabbCcbCcBCCbBaBabBcBBcACbbCCBCBbCcCBCaACcCBcAABAaaCbbCcbBBcCcbcBbbBaaAbcbacBcacABBbbAcCCbABcCAabBcCBBbBBAbbBbaBccCccCcBcaBAcbCaBcBbaccbccABacBAAcccAccABbBAcbccAAacCbCCccCCcCACcbaCaaCAcAAaAbcBbccacbbBbBABbAcaaAacABCACAbBbaCbaaaAACbACcBabaBAAbcCCAaaAaBcbcbbacCAAbBCACbCabcCAACbcCaCacBacACaCaCBcccaACabbAcBBbBaACaAcBBaaCbAcCcbccbAaBBbbBCbaabaabaBAAAcCbaccAbaBCACBbaAaCCBCCaABAbabcCBcBCaBaBcAABBacACbccBCcCaaCaBbABbbabCACAcACbcbACBcCBbcaCbBBabCbBcCCCcbBabBcbABBbbbaabCCaAcbAaaCBacCbCbACbcBacABbABBBAacBaBaAABcAacaaAacCaCaCabBaBACcccbaABaAcABcbacaAbCbBbbcccabCbaABBaaAbBBaaCBcaCcaBabABCacCbaCcBBcbcbAabCaBaaaCacbbbacBBaaBcbaBAAcccbcbaaabbbcBBBBbbBAcABCCaBCABAAaAcCBBACcBCBCbcBcACcbacBcABaabaaAbAABBcCcBCBBcccAbAacBCbBaBCCCcAcCaaCaccBabcacbbBCCBbCaabaabbbAbbBACCbbCcACbaacAccabCacaBbCAAcBABAccaCCCbaCAacAbabAacCaBCcBaCbBACaACBCBbabaCBbbBBbbCbabcCabCaBbBcAcCCaAcabBaBCcBAabababCbCBcCcccAbCaAbCaAacbCBaCccaBBcBcAcbcacABBCCacACAbCbaaaCCcCAaAabBCCcCCbcbCcccCaAACBaBABcCBcAACbaaCbbAAbCCbaccaaBbcBcabcABaaAbbcbCABcaBcaCCcCBBCcBaCaCbBcbccACaAcaCCCBBBaCCCCbCccbACBBbcCbbbCaAABbBAACbCcBBcABaBAbbCBbAcCccACBaCCacCaaBcAcbbBbABbCBCAcbCcACAABAbABCBCBbAbcAaCCbBbcbCcaacCcAaAcBcCbBccAbBAcCACbBBacACAcbCcBBCBCABCAbbacBcaabcbCbAcBCBBBabBAaBaCABAababccbAaCCBAbBbBAbccbaaCCCBBaBBAbaAbBcCCBaCcAAbbBBaAbacBcbCcCAcACAcCbCBaaCCBcBCcACBAbcBbAbBCBAaAAAaaabcacCBbBBCbbAccccaAcbbAaACCbbcbbACACcAaBcBcBBABCBBcbBbAaACACAcbaaBccCbaabaCCAcCaaCBcBcCbCbCbCBCBaAcACCCABcccaCBbcCBcbCbaBbCcBbcbBCAAcBbCcaAbABcAacBBbCacCACaabaabacbCababCAcBaAAAACAccccabCCBcCCcaccAACbbBABaCcbCbCbcBacbBCAcBcCbbCbBbbbCBBaabBBbAaabbBACCAbAcCBAAaaCbCBbAbAbAbaaACbABbaCABAacAAABbbAbCbacBcAAAAcAAABbAcAbaaBCbcCaBCabCBbaBBBcACCbAccABbacCccBbBbCBbbabcacCbbAAaBCbccABBBbAcaCCBcaaaaCabaCAcAaBaBbBacaCabAbcAaAAbCaaBAbbCcbcAcaCcbcAACaCbbCaABCAACbbCcbbBbcABaCaBaCabCBbABBcbBbCaCbCbcacaCbcACacabCABCBBAAAccAAbcAAacCBBaCACcbcBCCABbcCbabcaccBbbAaAbbcBcbbccCbbcBCcabBBAbcAbCAbCCACAAACACcBccaAcAAaBcAbBaabABCbacCcAACaAbCCcaAbcacAbbBbCBbCBbAAcBBcCAaaCbBBBcbCBAACcAaaACbCAABABAACcbCbcaacccbBCaBBcbAcCBbCbBBBABCaCbbbACCAcAAbbAACBBabcbaAaBBBCAAbbbCBCacBBCbCBBCaaaBbbbbacCCBCACbbbCcBBBcbcAccbBaBaccabBaBbAbbCCaBbbCCbbCbBAaCaBbAccAcbAcBBAaCbCbaCACcABaabAbBAAcAccAabaBaCbBbaBCAccacBaacBAbbACcaBBbaacbcAcABbAacBBaAcCBacBBbCaaaAaCbBbCCaCaacBAcCcBabAcABaACcCbAAaCAccacBabbbCCCCcBAaABCaaACACaabcCaaacbaCAbcAbaaCAbababAACCcBbccabBBbAacCcBCACccbBABabCaBBBacBCBAACACcCBbCaCacabccbBacbcCbBCccCBbAaACbbcaBccBaBabAbAbCbBBaCbCacbcBccbAbbbcbacccCCbBCcCAbCbaBABbccaAABBcCcAcCBaaaccacAbCBacccAbbAacaAbABbcBaCCABBcCaBaaaaAcbaCcaabBCcCBaaabBBaacAcbBBBBbcCbBcAABBcCCaaBCBCABBBAccBabcBCBCccBcBccaacCBBAbaBBCBbaAaAababcbaCACbBcBCCcABaCAACaababBCCbbbcCbbAcCaAACBcCbBbCBccBCBABCCAcAAABcCBcabCaCcbacbcabaBabBcabAcCACBbABbCCabABBccBBabbbABAAbBAbCBBabaCcACbBBaCAAaCAcBACCCaBabCaCbCabABcCbcCabABCccbAcCAbbcaAACbaAbcaBbaCBaAaaaCcABbaBaBCaAcbCcaAaBcCcbaABbBaCaCacCcaaBACbAccaccBccacAcbBCcBAbaccaBccBbabAcAcACbbacCaABbaBBBaaCaccABACAaBcbCbBBbaBaBBcABAaBCcBbAbcCBcbaBCBCBCCccCabAaCBbAaabBbcaaABbaABBbCcBBaACABABBaCBcBabaBAbBbaBaaccccCcCBcaaAaacAaAcbaBaaACacbBCcAcCBbAAAaACACBAbBabBbACbCaAbCCbbbaCACcCbacabBaBbbCAbCcaAcCbCbBBCACCbcaabbAcaCAabBcaccAaAacCCbBcAccbAAbaBABacbbbcBBAaaCBcCAbAAaCcaBabBCCCaBAbBCCcAbbaCcAcbBAcBBBBaCCBcbBCCCBbcCaCCaCABaabcbaaBaacCBaBcAAAbbAabaBCabAbaABBBAAcbBAbAccabBBaaacaACbBbAbaacBCCbCBbBabBbBCBabBCBAbBcAbAabAacBbCCCacaCBBBAcBCcBcBCbABbaaacbBbBcaccacBcaABBabBbccBAACBCBBCBcbcacBBaccBAbabcBBCACBaaCBABcaACABaABBaBbAcCAAbACCaCbCCCbCBaAbCBaCcCaaCaCBCCaaACABABBbAAAaAabbAaaAbCCBcABaCbCccBbaaCCBAcCbABccBACCCccCbcbCbcCABccaABAacaCBabBCbcABcAccbAaBBCAaaABbbbACaCbAccaAcCAbbABccCbcbcBCaccCbCBCaBCCCACbCbaaABbAaaAcBbAaBCCbcaBAcaBaCBBacacAAAbAcbCaCaBCbACCcaaABBAaaabBBccaaaAcCBbcBAaaabbABCbBbaABaCCccACCcCaccCabBbCCBACABCccaBcCAAAcCbBcBbBaCAbcBaacBABBACbAcCcBcAaabAbCbabBccAaBcBCbACabbBaaBBcBCBaaCbcBACcaACcCAcAaacbccbcCBBACbBAcCAAcBbBaaAccbBBAAbcBCbbabaCACAAabbaCBcaBAabcACAbaABaACacacbbbAAACCCbCcaABcBCBAabBcbacaabBcbbbAaBcbBbaAcbABCcCABcaAcAbabBbcabCbaCbCAbaCCCcbcAcaBbbbABAaaACabbbCCbaCbbaCBBCBbacACaCcABBbCAacaCCcBCCAccbCcaCabBbCABCbBACBACaCAaCaAAbaCCbCccbcccbacaAacaBAaacbAcaCaCbAcCBaCCbAbCCCaACacBcAaaABacaCCBbbAACbBCCCcBCBCCAAcabCCbCAbacAAbcCBCbabbBbACbCcACBbCBCCbbCCCBccbBABAAACaCbBBababCCAbbbbacbBbBbBcAaBbABAbBacbAbcbCbCaBcaAbabbBacaACCCAcbcCAbCabaBaCABBBacCabCcAaCABaCcCBacBbAbbCAcaBBcBcBbCAbbAbBABABabaCCBcCBCaaBaCAAcCabCaCCCaaBbAaAbbCCabAababABBBcCCbBCbbaCbbcCbBAaacaCbcAAAbbCccaAaaBBccABBAbBabCAAABcBBCcAAcCcaAacbBAcbABaAABabcABaaACBaBaCBAbacBCabbaaaBcbcCcbaCcACaACaABaABBcCcBcACbccbbbcacCCaABCbCcbbcBacbCBaCcacbcCBaBAcCCbbaAaCcbCCCaaBAbAAcaACCaCbBAbcACbAAaCBAcaCbcaABCaBaCAcabCCccCBCacbcbBBCbbcCCCacccAbcbccAcaaCBcBcBaabCcBaBAAACbAbBAaABAcaBcaacbACbAccAAbbCACbcBccaAaccABCaCbBaCAaCAACBAABBcACbCBcbabbABbcAabBAaBBCbbbabCBccBabbBcACaAAAcCcacbAbaAcaACbCBBaAccCcCbbCcCBbbCaABcCCbBaaaBcbAcCCBbBacCAccCaABcCABacBbacCCbBbBCbBaBBBBbACbbBaCAcaCBaCBBcBAcaBCCAAcCacBaBACbBAABaACCbbbBBaAaabBAaAcCBAcaABCccaACBccBCAbacCAcAAbBaaAabABaBBBacbbbAaACcBCcbbABabAacaCAbCbcCbBCaaAbBaCcaAABBcbAcCCCbBCaCbacBAabbbCBaABcAbcaAaCaABCbCbAaaaABaaCbcabBCabcccCcaAAbacCcbAAAabBacccbabAbcACCcCBBCbBcBcAcBCcbAbCBCcACCBBCBBbBccCACCaCAAccabAbCAAAabbACCBBAcbaBBaCaABCcbbcbBbccCACBAcCBCaBbCCAAAAcaBbbCaccAcAABBbaCaACbcbCACaBbcAACacCacAccabbbBcBbAcccABbcBBCBCbAACbabBCacABcCabcccaBCbCaCCbcCAacAaACbcaBCbAABbCCCcCaCbABcacABaCCaBAbaabBbaBCBAAcbcCbcCbAAAACABBCbBabCCabaCBCABbBCcCCAAbbbCACbCCBBccAcBBcbcBAAbbAAbbBBAcCACbabaACcbABbccaaCbbcBacCcAAcCbbaBBAacCAaAbCCAaaaAaCCBABCCbCcaacBAACbBaCBCAbACcABabACBCabCBAbBCAbbaCaCCCbBaAAaAACCCBbBCbcabbBbBaacABCBbCCBBBBABABAAABABcccacbAABcACBcbaBBCcBBaacaabacACcbcBAbCACcCBBAcCcACcBbABAcccACBAABCacACACAbababbcABAabCbcbcAcAaCAaCBAACCcbaBabABABAabBACBcAccCBaaCBbAaBccAAbAacCCBAaABaAaBaCABaCccaAbccabcabACbCBbCAaaAaBCbACCcABCaCCAcaaAbBaCcaABBBbCBCaAaCAabaAbcccbCCbaaaccCbcaCbAaCAcCABbCabBBBbaAbBaAaAaBCbABaCBCbaBBabCACABccBcbAcbAabcCaBCaacacaBaCbabCaCaCacAacAbaabcbCBaAABbCbcbccBbbAAaCAbbbAbBabbaAaCACAaCaaBBBACBaCAcAcBbaBcbcbcCAaACCBbBccABacAACbcbBBcABaCABAbCaaacACbaBbbCCACcBaaCCbcCCbbCabAAbABaaAcaBBCaBCcBcCAACbbCBaAbCBBcaBBcBbBBaCcAACACABabACbbBaaAAAbCBACBaACcbACaAcAabcAcAcAccaBCAAAbabABAaBbBcBAACACAbAbBCCaccBaabacBcaABAcABCcBAbcbAabbCABbbBcBbBcbabCAaaAcBbACacBCaABaccBaCaaaaBCACAABbCcbaCAacAAAaaBbBBcBbBbACbbccBaAABBaCbacCccAbbAabCCAAbBbbabCABBACbbABBaBBabbaACCCbACBbBbcAabcCbbabCAcaBAacAAAabCcBbCacabABcBcCaBbbAbabcAAcBCabbAbBcabbbbABaAABCbaaBCABBbaCaBbAbAbaBCAbabACbBabaccAbBBBBCAbABcAbbCABcCbBCaBABcaAbCaAaAcbcabaBCacaBaCCaAbBCBbAccBaCcaaCACbBcaBabAcCaccbCCcabCBBAABaaabAcCCBacCccacbccaCCacaABAACaBCaBCbBABbcbbbbBBABaaAbaBabBCcbbbabccCabBcACCACabcAABCbCACCabcAcaaabAbcBBbBAACcBCcABbCBccabAabACbCaCCcbcaBcbaCCcCaBabaabbcBbabAaacBcbbabccBaBbCBCCaBbaBAaCBCabcAcAcccbbbAcccBBBABbAAbbBAAbCBACCBAACCaABbcABaCcbcbaaaCBAACBacBBAbBaacBaCbbBabCaaacCBCBbCAaaBaBAaCcCAbbacBcCbaAaaacCCabCAAbcAAbABcBcccaAACCABaCcbbaAbcBaBCaCbbBCBCCBbCBbCcCCCBBAaAAcBacCbbAbcACABAbaBaCbaabccbAbCbbAaCacAbAacabBcBbbAbCAbbACAABBaaACAAAaCCcAabBbcbBbbccBCaAaBBBccbBAcbCBccABCcbcbAcBcACBCABBbABBbbaabbcBAbBCBaaBbAaaaabaaCcCBBCcACaBcABCAAaAbaBCAcaCbCaBaCCcABcAaBCaCbBbbBbCcbCCbAcbBcaBACaACBABbaBCCabbcAAAcBcaBBAAccbAbbCBCbaAbccaAbCCAAcabcCcBcACbaaaBAcBAcAabaCaaBaabcbAAcCcBAacbabaaBccaAabCbBcBbabCcCbBBCbaABACcBbcBCccacCaacABBaBCbAACbAAABaaaCbbBcBbCBCAaAaBCaCbcaCBABabccBAbabbCBbcBBaBCcabcBbacAcbBaBAAcbcAaaBAAAcaCBbcacaAbcaAAABBACAAbaaBBAbabCaCABBbBCBCBBAbAcaBbAcBbABAbacbAcbAcCaaABAAbbbBCbBbcAAACacBcAAacaBAAaaBcbbbbCAACcCaCBBcaCcBABcaCBBaABAAcAacCCcAaCAacbacacbCabABBCabcAcACBcAaCcAbBCbBBabcCAbBaAAABaCbCAAAcaBcAAabBAcCCABCBacBbaBBCbBAaCcBbaAbabBCCbacCbbCCBCccAcBBACABABaBcAbAaAbCACaBAAcBbcBAcAAbCBbBBCcCCACaCcBcaaccCBABCBaCcaBBbaBCCcaCAaBcAbabCcBbaaBBcBbBcaabBbBcABBAAcaCBcbbbbBCBcaBACcBBCBCCBacBbaAabbCCbbabaBCBbbbCcCABCbaBCbcbAAACAbbcbaaABcaACbABBbBACcbCBbAAcAAaBAbAAABcBaAacCaaCABCCAAAbCBACcCBCBbaaaBbBaaBaaCCAAaaBaBbbaCaBabBcABcCBAbBabbccbababbCACACACcCbBabACCCbcBcAbACbCbABccbacAcaBbbABcccBAbcAaBBBcbCaCBAcBcAccbbbbaBbbaaAbAaBacCbaBBBBaCacBcBCBCbBbabaCCBcCcacacbcAaaaABaaaaBccAcbaCcCcaBccABbbCaABcACaCaAbCaCbBBbBCcAaACBBaCbaCBCacaCAaACaCaCCbcAbCBBABAaACcbCCcaACCCACAcCCCcbBcBACcCCacbBBbBcAbaaBCbaACaacAACbbabCABbcCBBbcaAABBCababbbAbBABcccbACAAbCcbCCbABBccaaaBCcAcAcbABccCCbbaBbcCBBAaaCCAAaCcacCAcBAAAaAaaBCABbAcAAacCCBcAbcBCcAAacbaaCCbacAcbaCbbCaBcCCABBBbCABAbabbbBcaCACaccCAACACaAABBBCcAbAabBBcbbcACbcAccbbBBACAACcBBabcCCbCACBcaaccAbBaBaBbAabaCbAAAaaCcabCABabCbabbCaAbacCbCcaCCbBcAaabbbBCaaCcACBBaaCCACCBabABacbcCaBBBAcbacCBbCBAbaAaCbCbCBBBaaCcabaCAaaBccbCbBACAaCCbbAbABcbACCCbbAcaAaBccAAcBBbbbacaBcBCacbcBCAaBCAAaBcCababCAcAcCacAcAcccaCAaCaBCcACBaAbCbbaacacBCBccBCCbBabbbAAabCABcCACcaCBbCAABAABbcAcAAccAbcbbAAcaACaacAAAbCCAbBcCCbAACCCbCabbaCbCabBAaaAcABBbbBCbCCcBaCBbbCCabAcAcBacAcBacaAACaAbaBBaBbccBBABcccAAaBcccbbaBacBBacbBccbBCbaaacbCCBCBCcBaaccbbacbbccaCcabBCccBBAbbBcaCbaAA"
