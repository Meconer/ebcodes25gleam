import gleam/int
import gleam/list
import gleam/result
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

fn tree_build_helper(tree: TernaryTree(Int), n: Int) -> TernaryTree(Int) {
  case tree {
    Leaf -> Node(n, Leaf, Leaf, Leaf)
    Node(value, left, middle, right) ->
      if n < value {
        Node(value, tree_build_helper(left, n), middle, right)
      } else if n == value {
        Node(value, left, tree_build_helper(middle, n), right)
      } else {
        Node(value, left, middle, tree_build_helper(right, n))
      }
  }
}

pub fn build_tree(data: List(Int)) -> TernaryTree(Int) {
  helper(0, data)
}

pub fn q5p1(input) {
  let assert [_id, data] = input() |> string.split(on: ":")
  let data =
    data
    |> string.split(on: ",")
    |> list.map(string.trim)
    |> list.map(fn(el) {
      case int.parse(el) {
        Ok(n) -> n
        Error(_) -> 0
      }
    })
    let tree = build_tree(data)
  echo data
  ""
}
