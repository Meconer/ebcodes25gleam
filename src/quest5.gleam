import gleam/string

pub type TernaryTree(a) {
  Leaf
  Node(
    value: a,
    left: TernaryTree(a),
    middle: TernaryTree(a),
    right: TernaryTree(a),
  )
}

pub fn q5p1(input) {
  let assert [_id, ..data] = input() |> string.split(on: ":")
  data
}
