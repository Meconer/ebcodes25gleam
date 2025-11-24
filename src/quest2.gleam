import gleam/list

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
            True -> #(new_r, -1)
            False ->
              case y > limit || y < -limit {
                True -> #(new_r, -1)
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

pub fn make_range(start, stop, step, list) {
  case start > stop {
    True -> list.reverse(list)
    False -> make_range(start + step, stop, step, [start, ..list])
  }
}

pub fn q2p2() {
  let a = input_p2()
  let #(xtop, yleft) = a
  let diff = 1000 / 100
  let cols = make_range(xtop, xtop + 1000, diff, [])
  let rows = make_range(yleft, yleft + 1000, diff, [])
  list.fold(rows, 0, fn(acc, row) {
    list.fold(cols, acc, fn(acc, col) {
      let coord = #(col, row)
      let #(_final_r, cycles) = calc_cycles_p2(coord, 100)
      case cycles {
        0 -> {
          acc + 1
        }
        _ -> {
          acc
        }
      }
    })
  })
}

pub fn q2p3() {
  let output = ["P3", "1001 1001", "255"] |> list.reverse()
  let a = input_p2()
  let #(xtop, yleft) = a
  let diff = 1
  let cols = make_range(xtop, xtop + 1000, diff, [])
  let rows = make_range(yleft, yleft + 1000, diff, [])
  list.fold(rows, #(0, output), fn(acc, row) {
    list.fold(cols, acc, fn(acc, col) {
      let coord = #(col, row)
      let #(_final_r, cycles) = calc_cycles_p2(coord, 100)
      case cycles {
        0 -> {
          let #(cnt, output) = acc
          #(cnt + 1, ["255 255 255", ..output])
        }
        _ -> {
          let #(cnt, output) = acc
          #(cnt, ["0 0 0", ..output])
        }
      }
    })
  })
}
