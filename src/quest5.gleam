import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order
import gleam/string

pub type TernaryTree(a) {
  Leaf
  Node(value: a, left: Option(a), sub_tree: TernaryTree(a), right: Option(a))
}

pub type Sword {
  Sword(id: Int, tree: TernaryTree(Int))
}

fn tree_build_helper(tree: TernaryTree(Int), n: Int) -> TernaryTree(Int) {
  case tree {
    Leaf -> Node(value: n, left: None, sub_tree: Leaf, right: None)
    Node(value, left, middle, right) ->
      case n < value {
        // Check left because n is less than the middle value
        True ->
          case left {
            // Left already occupied
            Some(_left_val) ->
              Node(
                value: value,
                left: left,
                sub_tree: tree_build_helper(middle, n),
                right: right,
              )
            // Left unoccupied
            None ->
              Node(value: value, left: Some(n), sub_tree: middle, right: right)
          }
        False ->
          case n > value {
            // Check right because n is greater than the middle value
            True ->
              case right {
                // Right already occupied
                Some(_right_val) ->
                  Node(
                    value: value,
                    left: left,
                    sub_tree: tree_build_helper(middle, n),
                    right: right,
                  )
                // Right unoccupied
                None ->
                  Node(
                    value: value,
                    left: left,
                    sub_tree: middle,
                    right: Some(n),
                  )
              }
            // n is equal to value, go to middle
            False ->
              Node(
                value: value,
                left: left,
                sub_tree: tree_build_helper(middle, n),
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
      let assert Ok(n) = int.parse(el)
      n
    })
  let assert Ok(int_id) = int.parse(id)
  #(int_id, data)
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
      let assert Ok(n) = int.parse(answer_str)
      n
    })
    |> list.sort(by: int.compare)
  let assert Ok(smallest) = list.first(tree_vals)
  let assert Ok(largest) = list.last(tree_vals)
  largest - smallest
}

fn tree_value(tree: TernaryTree(Int)) -> Int {
  let assert Ok(n) = tree_to_string(tree) |> int.parse()
  n
}

fn get_str(i: Option(Int)) {
  case i {
    None -> " "
    Some(i) -> int.to_string(i)
  }
}

fn print_bar(tree: TernaryTree(Int)) {
  case tree {
    Leaf -> Nil
    Node(value, left, middle, right) -> {
      io.print(get_str(left) <> " - ")
      io.print(int.to_string(value) <> " - ")
      io.println(get_str(right))
      io.println("    |")
      print_bar(middle)
    }
  }
}

fn print_sword(sword: Sword) {
  io.println(int.to_string(sword.id) <> ":")
  print_bar(sword.tree)
  io.println("")
}

fn sword_val(tree: TernaryTree(Int)) -> List(Int) {
  case tree {
    Leaf -> []
    Node(value, left, middle, right) -> {
      let s =
        get_str(left) |> string.trim
        <> { int.to_string(value) |> string.trim }
        <> { get_str(right) |> string.trim }
      let val = case int.parse(s) {
        Ok(i) -> i
        Error(_) -> panic as "Cannot parse int"
      }
      [val, ..sword_val(middle)]
    }
  }
}

fn sword_compare(a: Sword, b: Sword) -> order.Order {
  let sword_a_val = tree_value(a.tree)
  let sword_b_val = tree_value(b.tree)
  let res = case int.compare(sword_a_val, sword_b_val) {
    order.Lt -> order.Lt
    order.Gt -> order.Gt
    order.Eq -> {
      // If values are equal, compare by fishbone values 
      case fishbone_compare(a, b) {
        order.Lt -> order.Lt
        order.Gt -> order.Gt
        order.Eq -> order.Eq
      }
    }
  }
  echo res
}

fn fishbone_compare(a: Sword, b: Sword) -> order.Order {
  let a_fishbone = calc_fishbones(a.tree, [])
  let b_fishbone = calc_fishbones(b.tree, [])
  compare_int_lists(a_fishbone, b_fishbone)
}

pub fn compare_int_lists(a: List(Int), b: List(Int)) -> order.Order {
  case a, b {
    // Take the first element of each list 
    [head_a, ..tail_a], [head_b, ..tail_b] -> {
      case int.compare(head_a, head_b) {
        // If they are equal, move to the next elements
        order.Eq -> compare_int_lists(tail_a, tail_b)
        // If they are different, stop and return the result immediately 
        diff -> diff
      }
    }
    _, _ -> order.Eq
  }
}

pub fn calc_fishbones(tree: TernaryTree(Int), acc: List(Int)) -> List(Int) {
  case tree {
    Leaf -> acc |> list.reverse()
    Node(val, left, middle, right) -> {
      let l_val = level_val(left, val, right)
      calc_fishbones(middle, [l_val, ..acc])
    }
  }
}

fn level_val(left: Option(Int), val: Int, right: Option(Int)) -> Int {
  let left_str = case left {
    Some(n) -> int.to_string(n)
    None -> ""
  }
  let val_str = int.to_string(val)
  let right_str = case right {
    Some(n) -> int.to_string(n)
    None -> ""
  }
  let val = left_str <> val_str <> right_str
  let assert Ok(int_val) = int.parse(val)
  int_val
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
      Sword(id: id, tree: tree)
    })
    |> list.sort(by: sword_compare)
  echo swords
  55
}
