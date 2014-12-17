open LazyList

let profile_case label thunk = Profiler.(
  profile ~times:100 default thunk |> print_stats Format.std_formatter label;
)

let force n ll =
  force n ll; ll

let gen_list n finit =
  let rec iter i l =
    if i < 0 then l else iter (i - 1) (finit n :: l)
  in
  iter n []

let n = 10*1000
let l = gen_list n float
let a = Array.init n float

let profile_baseline =
  profile_case "Baseline"
    (fun () -> ());
  ()

let profile_from_callback =
  profile_case "from_callback"
    (fun () -> force n (from_callback
			  (fun k x -> k (x +. 1.0))
			  0.0));
  profile_case "from_callback0"
    (fun () -> force n (from_callback0
			  (let rx = ref 0.0 in
			   fun k -> let x = !rx in
				    rx := x +. 1.0;
				    k x)));
  profile_case "from_callback2"
    (fun () -> force n (from_callback2
			  (fun k x -> k (x+1) (float x))
			  0));
  ()  

let profile_from_thunk () =
  profile_case "from_thunk"
    (fun () -> force n (from_thunk
  			  (let rx = ref 0.0 in
  			   fun () -> let x = !rx in
  				     rx := x +. 1.0;
  				     Some x)));
  profile_case "from_thunk_exc"
    (fun () -> force n (from_thunk_exn Exit
  			  (let rx = ref 0.0 in
  			   fun () -> let x = !rx in
  				     rx := x +. 1.0;
  				     x)));
  profile_case "from_thunk_exit"
    (fun () -> force n (from_thunk_exit
			  (let rx = ref 0.0 in
			   fun () -> let x = !rx in
				     rx := x +. 1.0;
				     x)));
  ()

let profile_generation () =
  profile_case "cyclic"
    (fun () -> force n (cyclic 0));
  profile_case "repeat"
    (fun () -> force n (repeat 0));
  profile_case "iterate"
    (fun () -> force n (iterate 0.0 ~step:(fun x -> x +. 1.0) ()));
  profile_case "from_list"
    (fun () -> force n (from_list l));
  profile_case "from_array"
    (fun () -> force n (from_array a));
  ()

let profile_transform () =
  profile_case "filter.map"
    (fun () -> force n (map
			  float
			  (filter
			     (fun x -> x mod 2 > 0)
			     (count_up 0 n))));
  profile_case "filter_map"
    (fun () -> force n (filter_map
			  (fun x -> x mod 2 > 0)
			  float
			  (count_up 0 n)));
  profile_case "transform"
    (fun () -> force n (transform
			  (function
			  | x when x mod 2 > 0 -> Some (float x)
			  | _ -> None)
			  (count_up 0 n)));
  profile_case  "transform_with_callback"
    (fun () -> force n (transform_with_callback
			  (fun k -> function
			  | Nil -> Nil
			  | Cons (x, t) when x mod 2 > 0 -> Cons (float x, lazy (k t))
			  | Cons (_, t) -> k t)
			  (count_up 0 n)));
  ()
