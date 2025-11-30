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

fn string_to_data(input: String) -> #(Int, List(Int)) {
  let assert [id, data] = input |> string.split(on: ":")
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
  let id = case int.parse(id) {
    Ok(n) -> n
    Error(_) -> 0
  }
  #(id, data)
}

pub fn q5p1(input) {
  let #(_id, data) = string_to_data(input())
  let tree = build_tree(data)
  let answer = tree_to_string(tree)
  answer
}

fn tree_to_string(tree: TernaryTree(Int)) -> String {
  rec_to_string(tree, "")
}

fn rec_to_string(tree: TernaryTree(Int), string: String) -> String {
  case tree {
    Leaf -> string
    Node(value, _left, middle, _right) -> {
      let string = string <> int.to_string(value)
      rec_to_string(middle, string)
    }
  }
}

pub fn q5p2(input) {
  let inp_list = string.split(input(), on: "\n")
  let tree_vals =
    inp_list
    |> list.map(fn(line) {
      let #(_id, data) = string_to_data(line)
      let tree = build_tree(data)
      let answer_str = tree_to_string(tree)
      case int.parse(answer_str) {
        Ok(answer_int) -> answer_int
        Error(_) -> panic as "Failed to parse answer_str"
      }
    })
    |> list.sort(by: int.compare)
  let smallest = case list.first(tree_vals) {
    Ok(n) -> n
    Error(_) -> panic as "Empty list"
  }
  let largest = case list.last(tree_vals) {
    Ok(n) -> n
    Error(_) -> panic as "Empty list"
  }
  largest - smallest
}

pub type Sword {
  Sword(id: Int, value: TernaryTree(Int))
}

fn tree_value(tree: TernaryTree(Int)) -> Int {
  case tree_to_string(tree) |> int.parse() {
    Ok(n) -> n
    Error(_) -> panic as "Failed to parse tree value"
  }
}

fn sword_compare(a: Sword, b: Sword) -> order.Order {
  let sword_a_val = tree_value(a.value)
  let sword_b_val = tree_value(b.value)
  echo "Comparing Sword"
    <> int.to_string(a.id)
    <> " with value "
    <> int.to_string(sword_a_val)
  echo "to Sword "
    <> int.to_string(b.id)
    <> "with value "
    <> int.to_string(sword_b_val)
  let res = case int.compare(sword_a_val, sword_b_val) {
    order.Lt -> order.Lt
    order.Gt -> order.Gt
    order.Eq -> {
      // If values are equal, compare by id
      case int.compare(b.id, a.id) {
        order.Lt -> order.Lt
        order.Gt -> order.Gt
        order.Eq -> order.Eq
      }
    }
  }
  echo res
}

pub fn q5p3(input) {
  let inp_list = string.split(input(), on: "\n")
  let swords: List(Sword) =
    inp_list
    |> list.map(fn(line) {
      let #(id, data) = string_to_data(line)
      let tree = build_tree(data)
      let answer_str = tree_to_string(tree)
      case int.parse(answer_str) {
        Ok(answer_int) -> answer_int
        Error(_) -> panic as "Failed to parse answer_str"
      }
      Sword(id: id, value: tree)
    })
    |> list.sort(by: sword_compare)
  echo swords
  55
}
