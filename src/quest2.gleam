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

fn cycle_p2(r: #(Int, Int), coord: #(Int, Int)) -> #(Int, Int) {
  let r = multiplication(r, r)
  let r = division(r, #(100_000, 100_000))
  let r = addition(r, coord)
  r
}

fn rec_cycle_p2(
  r: #(Int, Int),
  coord: #(Int, Int),
  count: Int,
) -> #(#(Int, Int), Int) {
  case count {
    0 -> #(r, count)
    count -> {
      let new_r = cycle_p2(r, coord)
      let limit = 1_000_000
      case new_r {
        #(x, y) -> {
          case x > limit || x < -limit {
            True -> #(new_r, count - 1)
            False ->
              case y > limit || y < -limit {
                True -> #(new_r, count - 1)
                False -> rec_cycle_p2(new_r, coord, count - 1)
              }
          }
        }
      }
    }
  }
}

pub fn calc_cycles_p2(coord: #(Int, Int), times: Int) -> #(#(Int, Int), Int) {
  let r = #(0, 0)
  rec_cycle_p2(r, coord, times)
}

pub fn q2p2() {
  let a = input_p2()
  echo a
  let opposite_corner = addition(a, #(1000, 1000))
  let coord = #(35_630, -64_880)
  let res = calc_cycles_p2(coord, 100)
  assert res == #(#(-2520, -5355), 100)
}
