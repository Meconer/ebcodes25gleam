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
      case n < value {
        // Check left because n is less than the middle value
        True ->
          case left >= 0 {
            // Left already occupied
            True ->
              Node(
                value: value,
                left: left,
                middle: tree_build_helper(middle, n),
                right: right,
              )
            // Left unoccupied
            False -> Node(value: value, left: n, middle: middle, right: right)
          }
        False ->
          case n > value {
            // Check right because n is greater than the middle value
            True ->
              case right >= 0 {
                // Right already occupied
                True ->
                  Node(
                    value: value,
                    left: left,
                    middle: tree_build_helper(middle, n),
                    right: right,
                  )
                // Right unoccupied
                False ->
                  Node(value: value, left: left, middle: middle, right: n)
              }
            // n is equal to value, go to middle
            False ->
              Node(
                value: value,
                left: left,
                middle: tree_build_helper(middle, n),
                right: right,
              )
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
