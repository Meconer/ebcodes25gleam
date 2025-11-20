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
