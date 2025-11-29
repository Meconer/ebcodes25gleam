import gleam/int
import gleam/list
import gleam/order
import gleam/string

pub type TernaryTree(a) {
  Leaf
  Node(value: a, left: a, middle: TernaryTree(a), right: a)
}

fn tree_build_helper(tree: TernaryTree(Int), n: Int) -> TernaryTree(Int) {
  case tree {
    Leaf -> Node(value: n, left: -1, middle: Leaf, right: -1)
    Node(value, left, middle, right) ->
      case int.compare(n, value) {
        order.Lt ->
          case value {
            -1 -> Node(n, Leaf, middle, right)
            _ -> Node(value, tree_build_helper(left, n), middle, right)
            order.Eq -> Node(value, left, tree_build_helper(middle, n), right)
            order.Gt -> Node(value, left, middle, tree_build_helper(right, n))
          }
      }
  }
}

pub fn build_tree(data: List(Int)) -> TernaryTree(Int) {
  list.fold(data, Leaf, tree_build_helper)
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
  echo tree
  ""
}
