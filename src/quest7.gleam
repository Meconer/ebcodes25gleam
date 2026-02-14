import gleam/dict
import gleam/list
import gleam/option
import gleam/string
import utils

pub fn q7p1(words: String, rules: String) {
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

fn check_word(word: String, rules: dict.Dict(String, List(String))) {
  string.to_graphemes(word)
  |> rec_check(rules, True)
}

pub fn q7p2(words: String, rules: String) {
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
