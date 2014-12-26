type t =
    { n		: int;
      precision	: int;
      mutable mean	: float;
      mutable sigma	: float;
      mutable minimum	: float;
      mutable maximum	: float }

type percent = float

let square x = x *. x

let sum series = Array.fold_left (+.) 0.0 series

let from_series ?(precision=6) n get =
  let s =
    { n;
      precision = 6;
      mean	= 0.;
      sigma	= 0.;
      minimum	= infinity;
      maximum	= neg_infinity }
  in
  for i = 0 to n-1 do
    let x = get i in
    s.mean <- s.mean +. x;
    s.minimum <- min s.minimum x;
    s.maximum <- min s.maximum x
  done;
  s.mean <- s.mean /. float n;
  for i = 0 to n-1 do
    s.sigma <- s.sigma +. square (get i -. s.mean)
  done;
  s.sigma <- sqrt (s.sigma /. float n);
  s

let from_float_series n get =
  from_series n get

let from_int_series n get =
  let getf i = float (get i) in
  from_series ~precision:1 n getf

let print fmt s =
  let p = s.precision in
  Format.fprintf fmt "@[mean=%.*f,@ dev=%.*f;@ min=%.*f,@ max=%.*f@]"
    p s.mean
    p s.sigma
    p s.minimum
    p s.maximum
