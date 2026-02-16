import gleam/bool
import gleam/dict
import gleam/list
import gleam/option
import gleam/result
import gleam/set
import gleam/string
import utils

fn get_words_and_rules(words, rules) {
  let words = words |> string.split(",")
  let rules =
    rules
    |> string.split("\n")
    |> list.fold([], fn(acc, line) {
      let parts = string.split(line, on: " > ")
      let assert Ok(pre) = list.first(parts)
      let assert Ok(post_str) = list.last(parts)
      let posts = string.split(post_str, ",")
      [#(pre, posts), ..acc]
    })
    |> dict.from_list()
  #(words, rules)
}

pub fn q7p1(words: String, rules: String) {
  let #(words, rules) = get_words_and_rules(words, rules)
  list.map(words, fn(word) {
    case check_word(word, rules) {
      True -> option.Some(word)
      False -> option.None
    }
  })
  |> list.filter(option.is_some)
  |> list.map(fn(opt) { option.unwrap(opt, "") })
  |> utils.unsafe_list_first()
}

fn rec_check(wlst: List(String), rules, is_ok) {
  case wlst {
    [] -> is_ok
    [_] -> is_ok
    [a, b, ..tail] -> {
      case is_pair_in_order(a, b, rules) {
        True -> rec_check([b, ..tail], rules, is_ok)
        False -> False
      }
    }
  }
}

fn is_pair_in_order(
  a: String,
  b: String,
  rules: dict.Dict(String, List(String)),
) -> Bool {
  let ok_list = dict.get(rules, a)
  case ok_list {
    Ok(list) -> list.contains(list, b)
    _ -> False
  }
}

fn check_word(word: String, rules: dict.Dict(String, List(String))) -> Bool {
  string.to_graphemes(word)
  |> rec_check(rules, True)
}

pub fn q7p2(words: String, rules: String) {
  let #(words, rules) = get_words_and_rules(words, rules)
  list.map(words, fn(word) {
    case check_word(word, rules) {
      True -> option.Some(word)
      False -> option.None
    }
  })
  |> list.index_fold(0, fn(acc, opt, idx) {
    case opt {
      option.Some(_) -> acc + idx + 1
      option.None -> acc
    }
  })
}

fn build_words(
  word: String,
  rules: dict.Dict(String, List(String)),
  min_length: Int,
  max_length: Int,
  word_acc: set.Set(String),
  visited: set.Set(String),
) -> set.Set(String) {
  let len = string.length(word)
  use <- bool.guard(when: len > max_length, return: word_acc)
  use <- bool.guard(when: set.contains(visited, word), return: word_acc)
  let assert Ok(last_letter) = string.last(word)
  let followers =
    dict.get(rules, last_letter)
    |> result.unwrap([])
  let new_words =
    list.fold(followers, [], fn(acc, follower) {
      [string.append(word, follower), ..acc]
    })
    |> set.from_list()
  let next_words =
    set.fold(new_words, set.new(), fn(innacc, nword) {
      set.union(
        build_words(nword, rules, min_length, max_length, set.new(), visited),
        innacc,
      )
    })
  case string.length(word) >= min_length {
    True -> {
      set.insert(next_words, word)
    }
    False -> {
      next_words
    }
  }
}

pub fn find_duplicates(items: List(a)) -> List(a) {
  let #(_seen, dups) =
    list.fold(over: items, from: #(set.new(), set.new()), with: fn(acc, item) {
      let #(seen, dups) = acc
      case set.contains(seen, item) {
        // If we've seen it before, add it to the 'dups' set
        True -> #(seen, set.insert(dups, item))
        // If it's new, add it to the 'seen' set
        False -> #(set.insert(seen, item), dups)
      }
    })

  set.to_list(dups)
}

pub fn q7p3(words: String, rules: String) {
  let #(words, rules) = get_words_and_rules(words, rules)
  let words = set.from_list(words)
  let found_words =
    set.fold(words, set.new(), fn(acc, word) {
      case check_word(word, rules) {
        True -> {
          let gen_words = build_words(word, rules, 7, 11, set.new(), set.new())
          set.union(acc, gen_words)
        }
        False -> acc
      }
    })

  found_words
  |> set.size()
}

pub const words_sample_p1 = "Oronris,Urakris,Oroneth,Uraketh"

pub const rules_sample_p1 = "r > a,i,o
i > p,w
n > e,r
o > n,m
k > f,r
a > k
U > r
e > t
O > r
t > h"

pub const words_p1 = "Azral,Siljorath,Vanral,Vanjorath,Silthel,Silral,Azjorath,Azthel,Vanthel"

pub const rules_p1 = "o > r
A > z
V > a
a > t,l,b
z > j,b
l > t,j,r
S > i
n > t,j,r
j > o
r > a
i > b
h > e
t > h
e > l"

pub const words_sample_p2 = "Xanverax,Khargyth,Nexzeth,Helther,Braerex,Tirgryph,Kharverax"

pub const rules_sample_p2 = "r > v,e,a,g,y
a > e,v,x,r
e > r,x,v,t
h > a,e,v
g > r,y
y > p,t
i > v,r
K > h
v > e
B > r
t > h
N > e
p > h
H > e
l > t
z > e
X > a
n > v
x > z
T > i"

pub const words_p2 = "Jaerzor,Helvor,Ardencyth,Zarathirin,Helaxis,Ardenacris,Ilmarfyr,Ilmarzor,Zarathketh,Tharilvor,Helgnar,Dorgnar,Ardencalyx,Cyndfyr,Zarathgnar,Tharilgnar,Zarathaxis,Dorcyth,Jaergnar,Dorvor,Tharilcalyx,Helcalyx,Ardenfyr,Tharilketh,Helketh,Jaeracris,Cyndacris,Ardenvor,Zarathacris,Helvor,Ilmarketh,Helfyr,Tharilfyr,Ilmaririn,Helketh,Ardenzor,Tharilzor,Zarathcyth,Zarathgnar,Ardengnar,Cyndvor,Helacris,Cyndcyth,Ardenaxis,Doracris,Cyndirin,Helgnar,Zarathketh,Dorzor,Zarathfyr,Jaercyth,Doraxis,Dorfyr,Zarathcalyx,Helaxis,Zarathvor,Dorketh,Helzor,Zarathzor,Helirin,Helcyth,Jaerfyr,Dorcalyx,Zarathfyr,Ilmarvor,Doririn,Ardenirin,Jaercalyx,Cyndzor,Helacris,Zarathzor,Ilmarcyth,Ardenketh,Tharilacris,Helcalyx,Helcyth,Jaeririn,Jaeraxis,Tharilirin,Jaervor,Cyndaxis,Jaerketh,Ilmarcalyx,Tharilcyth,Ilmargnar,Zarathcyth,Cyndketh,Helzor,Zarathaxis,Zarathcalyx,Ilmaraxis,Cyndcalyx,Helirin,Helfyr,Zarathirin,Ilmaracris,Cyndgnar,Zarathvor,Zarathacris,Tharilaxis"

pub const rules_p2 = "y > r,t,x,v
h > i,v,a,k,z,g,f,c
J > a
k > e
z > o
i > r,n,s,l
f > y
v > o
l > m,y,i,v,a,k,z,g,f,c
a > r,c,x,l,v,t
A > r
n > i,v,a,k,z,g,f,c,d
I > l
g > n
Z > a
r > f,v,i,a,k,z,g,c
D > o
C > y
o > r,v
T > h
e > n,t,v,r
d > e,i,v,a,k,z,g,f,c
m > a
t > h
x > i
H > e
c > r,y,a"

pub const words_sample_1_p3 = "Xaryt"

pub const rules_sample_1_p3 = "X > a,o
a > r,t
r > y,e,a
h > a,e,v
t > h
v > e
y > p,t"

pub const words_sample_2_p3 = "Khara,Xaryt,Noxer,Kharax"

pub const rules_sample_2_p3 = "r > v,e,a,g,y
a > e,v,x,r,g
e > r,x,v,t
h > a,e,v
g > r,y
y > p,t
i > v,r
K > h
v > e
B > r
t > h
N > e
p > h
H > e
l > t
z > e
X > a
n > v
x > z
T > i"

pub const words_p3 = "Ny,Nyl,Nyth,Nyss,Nyrix,Urak,Aure,Zyrix,Tarl,Fyr,Pyr,Brel,Ael,Malith,Rythan,Drak,Xyr,Rylar,Dal,Karth"

pub const rules_p3 = "M > a
R > y
r > t,i,v,e,l,r,z,d,f,k,a
e > l,r,z,d,f,k,a,t,v
Z > y
U > r
t > h
x > r,z,d,f,k,a,t
i > s,o,x,t
X > y
z > o,i
A > u,e
u > v
N > y
a > r,x,l,e,k,v,n
k > r,a,z,d,f,k,t
o > r,n
d > a
s > s,r,z,d,f,k,a,t
f > y
F > y
K > a
y > v,r,s
T > a
h > z,y,r,d,f,k,a,t
D > r,a
P > y
l > a,r,z,d,f,k,t,i
n > r,z,d,f,k,a,t
B > r"
