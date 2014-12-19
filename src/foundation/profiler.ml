type t = {
  gc_reset : [`no | `minor | `major | `compact]
}

type float_stat =
    { mutable mean	: float;
      mutable sigma	: float;
      mutable minimum	: float;
      mutable maximum	: float }

type stats =
    { delta_times	: float array;
      delta_allocations	: float array;
      heap_words	: float array;
      heap_blocks	: float array;
      time_stat		: float_stat Lazy.t;
      allocation_stat	: float_stat Lazy.t;
      heap_words_stat	: float_stat Lazy.t;
      heap_blocks_stat	: float_stat Lazy.t }

(*__________________________________________________________________________*)

let square x = x *. x

let float_stat_from_series series =
  let s = { mean	= 0.;
	    sigma	= 0.;
	    minimum	= infinity;
	    maximum	= neg_infinity }
  in
  let n = Array.length series in
  for i = 0 to n - 1 do
    let x = series.(i) in
    s.mean <- s.mean +. x;
    s.minimum <- min s.minimum x;
    s.maximum <- max s.maximum x
  done;
  s.mean <- s.mean /. float n;
  for i = 0 to n - 1 do
    s.sigma <- s.sigma +. square (series.(i) -. s.mean)
  done;
  s.sigma <- sqrt (s.sigma /. float n);

(*__________________________________________________________________________*)

let default = {
  gc_reset = `compact;
}

let reset_gc flag =
  match flag with
  | `no		-> ()
  | `minor	-> Gc.minor ()
  | `major	-> Gc.full_major ()
  | `compact	-> Gc.compact ()

let bytes_to_words b =
  b *. 8.0 /. float Sys.word_size

let profile p ?(times=1) thunk =
  let delta_allocations	= Array.make times nan in
  let delta_times	= Array.make times nan in
  let heap_words	= Array.make times nan in
  let heap_blocks	= Array.make times nan in
  let values		= Array.make times (Obj.repr None) in
  for i = 0 to times-1 do
    Gc.full_major ();
    let gc0 = Gc.stat () in
    let t0 = Sys.time () in
    values.(i) <- Obj.repr (thunk ());	(* Keep value alive *)
    let t1 = Sys.time () in
    Gc.full_major ();
    let gc1 = Gc.stat () in
    delta_allocations.(i) <-
      Gc.(gc1.minor_words +. gc1.major_words -. gc1.promoted_words) -.
      Gc.(gc0.minor_words +. gc0.major_words -. gc0.promoted_words);
    delta_times.(i) <- t1 -. t0;
    heap_words.(i) <- float Gc.(gc1.live_words - gc0.live_words);
    heap_blocks.(i) <- float Gc.(gc1.live_blocks - gc0.live_blocks);
    values.(i) <- (Obj.repr None)
  done;
  { delta_times;
    delta_allocations;
    heap_words;
    heap_blocks;
    time_stat		= lazy (float_stat_from_series delta_times);
    allocation_stat	= lazy (float_stat_from_series delta_allocations);
    heap_words_stat	= lazy (float_stat_from_series heap_words);
    heap_blocks_stat	= lazy (float_stat_from_series heap_blocks) }

(*__________________________________________________________________________*)

let print_float_stat prec fmt s =
  Format.fprintf fmt "@[mean=%.*f,@ dev=%.*f;@ min=%.*f,@ max=%.*f@]"
    prec s.mean
    prec s.sigma
    prec s.minimum
    prec s.maximum

let print_stats fmt label stats =
  Format.(
    pp_open_vbox fmt 4;
    fprintf fmt "%s:@," label;
    fprintf fmt "@[<2>time       (s) =@ %a@]" (print_float_stat 6) (Lazy.force stats.time_stat);
    pp_print_cut fmt ();
    fprintf fmt "@[<2>allocation (W) =@ %a@]" (print_float_stat 0) (Lazy.force stats.allocation_stat);
    pp_print_cut fmt ();
    fprintf fmt "@[<2>heap words (W) =@ %a@]" (print_float_stat 0) (Lazy.force stats.heap_words_stat);
    pp_print_cut fmt ();
    fprintf fmt "@[<2>heap blocks    =@ %a@]" (print_float_stat 0) (Lazy.force stats.heap_blocks_stat);
    pp_close_box fmt ();
    pp_print_cut fmt ()
  )
