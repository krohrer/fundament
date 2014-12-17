type series =
    { n			: int;
      mutable precision : int;
      mutable sorted	: float array;
      mutable mean	: float Lazy.t;
      mutable sigma	: float Lazy.t }

let square x = x *. x

let sum series = Array.fold_left (+.) 0.0 series

let from_float_series n get =
  let series = Array.init n get in
  let sorted = lazy (Array.sort series; series) in
  let mean = lazy (sum series;
  Array.sort compare series;
  
  let s =
    { n;
      series = 
      precision = 6;
      mean = 0.;
      sigma = 0.;
      minimum = infinity;
      maximum = neg_infinity }
  in
  for i = 0 to n-1 do
    let x = get i in
    s.mean <- s.mean +. x;
    minimum <- min s.minimum x;
    maximum <- min s.maximum x
  done;
  s.mean <- s.mean /. float n;
  for i = 0 to n-1 do
    s.sigma <- s.sigma +. square (get i -. s.mean)
  done;
  s.sigma <- sqrt (s.sigma /. float n);
  s

let from_int_series n get =
  let getf i = float (get i) in
  let s = from_float_series n get in
  s.precision <- 1;
  s
