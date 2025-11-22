fn addition(a: #(Int, Int), b: #(Int, Int)) -> #(Int, Int) {
  let #(x1, y1) = a
  let #(x2, y2) = b
  #(x1 + x2, y1 + y2)
}

fn multiplication(a: #(Int, Int), b: #(Int, Int)) -> #(Int, Int) {
  let #(x1, y1) = a
  let #(x2, y2) = b
  #(x1 * x2 - y1 * y2, x1 * y2 + y1 * x2)
}

fn division(a: #(Int, Int), b: #(Int, Int)) -> #(Int, Int) {
  let #(x1, y1) = a
  let #(x2, y2) = b
  #(x1 / x2, y1 / y2)
}

fn cycle(r: #(Int, Int), a: #(Int, Int)) -> #(Int, Int) {
  let r = multiplication(r, r)
  let r = division(r, #(10, 10))
  addition(r, a)
}

pub fn q2p1() {
  let r = #(0, 0)
  let a = #(151, 50)
  cycle(r, a) |> cycle(a) |> cycle(a)
}

fn input_p2() {
  // #(-79_785, -16_616)
  #(35_300, -64_910)
}

fn cycle_p2(r: #(Int, Int), a: #(Int, Int)) -> #(Int, Int) {
  let r = multiplication(r, r)
  let r = division(r, #(1000, 1000))
  addition(r, a)
}

fn rec_cycle_p2(
  r: #(Int, Int),
  a: #(Int, Int),
  count: Int,
) -> #(Bool, #(Int, Int), Int) {
  case count {
    0 -> #(False, r, count)
    count -> {
      let new_r = cycle_p2(r, a)
      let limit = 100_000
      case new_r {
        #(x, y) -> {
          case x > limit || x < -limit {
            True -> #(False, new_r, count)
            False ->
              case y > limit || y < -limit {
                True -> #(False, new_r, count)
                False -> rec_cycle_p2(new_r, a, count - 1)
              }
          }
        }
      }
    }
  }
}

fn calc_cycles_p2(a: #(Int, Int), times: Int) -> #(Bool, #(Int, Int), Int) {
  let r = #(0, 0)
  rec_cycle_p2(r, a, times)
}

pub fn q2p2() {
  let a = input_p2()
  echo a
  let opposite_corner = addition(a, #(1000, 1000))

  calc_cycles_p2(opposite_corner, 100)
}
