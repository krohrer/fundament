let times = 10
let n = 1000*1000
let burn_cycles = 10
(* Prevent inlining, I guess: *)
(* let rop = ref (+) *)
(* let operation = !rop *)
(* let operation a b = *)
(*   for i = 0 to burn_cycles do *)
(*     ignore (a + b) *)
(*   done *)
(*   ;a + b *)
let fmt =
  let write _ _ _ = ()
  and flush () = () in
  Format.make_formatter write flush

let operation a b =
  let s = a + b in
  Format.pp_print_int fmt s;
  s

let operation = (+)

let profile_case label thunk = Profiler.(
  profile ~times default thunk |> print_stats Format.std_formatter label
)

(* let int_vector = Vector.init n (fun x -> x) *)
let int_array = Array.init n (fun x -> x)
let int_list = Array.to_list int_array

let cont_with_result =
  if times = 1 then
    Format.printf "@.@[Result = %d@]@,"
  else 
    ignore

let profile_array =
  profile_case
    "Array/unfolded" 
    (fun () ->
      let rec loop arr i n sum =
	if i < n then
	  loop arr (i+1) n (operation sum arr.(i))
	else 
	  sum
      in
      loop int_array 0 n 0 |> cont_with_result
    );
  profile_case
    "Array/unfolded+closure"
    (fun () ->
      let rec loop i sum =
	if i < n then
	  loop (i+1) (operation sum int_array.(i))
	else
	  sum
      in
      loop 0 0
    );
  profile_case
    "Array/unfolded+closure"
    (fun () ->
      let count = n in
      let arr = int_array in
      let rec loop i sum =
	if i < count then
	  loop (i+1) (operation sum arr.(i))
	else
	  sum
      in
      loop 0 0
    );
  profile_case
    "Array/sequence"
    Seq_Prototype.(fun () ->
      let seq = from_array int_array in
      fold operation 0 seq |> cont_with_result
    );
  profile_case
    "Array/fold_left"
    (fun () -> 
      Array.fold_left operation 0 int_array |> cont_with_result
    );
  profile_case
    "Array/enum+fold"
    Enumee_Prototype.(fun () ->
      (array_enum int_array 0 (fold operation) |> cont_with_result)
    );
  profile_case
    "Array/s-enum+fold"
    SEnumee_Prototype.(fun () ->
      (array_enum int_array 0 (fold operation) |> cont_with_result)
    );
  profile_case
    "Array/enumi+inline"
    Enumee_Prototype.(fun () ->
      let sum = ref 0 in
      let rec it a (i:int) ~cont : int=
	sum := operation !sum a;
	cont i ~it
      in
      let _ : int = array_enumi int_array (fun i ~cont -> cont i it) in
      !sum |> cont_with_result
    );
  profile_case
    "Array/s-enum+inline"
    SEnumee_Prototype.(fun () ->
      array_enum int_array 0 (let rec it a m b cont = 
				cont m (operation a b) it
			      in
			      it) |> cont_with_result
    );
  profile_case
    "Array/cps-enumi2+linline"
    CpsEnumee_Prototype.(fun () -> 
      let rec it i cont stop a s0 s1 =
	cont it (operation a i) s0 s1
      in
      let k a _ _ =
	cont_with_result a
      in
      Array2.enumi int_array 0 k it
    );
  profile_case
    "Array/cps_enum+inline"
    CpsEnumee_Prototype.(fun () ->
      let rec it i cont stop a =
	cont it (operation a i)
      in
      let k _ a =
	cont_with_result a
      in
      Array0.enum int_array 0 k it
    );
  profile_case
    "Array/iteratee+inline"
    Iteratee_Prototype.(fun () -> 
      let rec it i cont a =
	continue cont None it (operation i a)
      in
      Array.enum int_array (fun _ a -> a) it 0
    );
  profile_case "Array/modular-fold"
    ModularIteratee_Prototype.(fun () -> 
      let rec it cont a i = 
	Fold.continue cont it (operation a i)
      in
      Array.fold it 0 int_array
    );
  (* profile_case "Array/unpuree" *)
  (*   UnpureIteratee_Prototype.(fun () -> *)
  (*     enum_array int_array (XCont (ref 0,  *)
  (* 				   (fun s -> ref !s), *)
  (* 				   (fun s i cont ->  *)
  (* 				     s := operation !s i; *)
  (* 				     cont), *)
  (* 				   (!))) |> *)
  (* 	  run cont_with_result ignore ignore *)
  (*   ); *)
  (* profile_case "Array/unpuree-2" *)
  (*   UnpureIteratee_Prototype.(fun () -> *)
  (*     enum_array' int_array (XCont (ref 0, *)
  (* 				    (fun s -> ref !s), *)
  (* 				    (fun s i cont -> *)
  (* 				      s := operation !s i; *)
  (* 				      cont), *)
  (* 				    (!))) |> *)
  (* 	  run cont_with_result ignore ignore *)
  (*   ); *)
  profile_case "Array/unpuree+inline"
    Unpuree_Prototype.(fun () ->
      let it =
	SRecur {
	  s=ref 0;
	  cp=(fun s -> s);
	  ex=(!);
	  ret=return;
	  k=fun st el ret cont ->
	    st := operation !st el;
	    cont
	}
      in
      execute
	~source:(enum_array int_array)
	~query:it
	~on_done:cont_with_result
	());
  profile_case "Array/unpuree+cont"
    Unpuree_Prototype.(fun () ->
      let sum = ref 0 in
      let rec it = Cont (fun i ->
	sum := operation !sum i;
	it)
      in
      (enum_array int_array) it;
      cont_with_result !sum
    );	
  profile_case "Array/unpuree+fold"
    Unpuree_Prototype.(fun () ->
      execute
	~source:(enum_array int_array)
	~query:(fold operation 0)
	~on_done:cont_with_result
	());
  ()

let profile_list =
  profile_case
    "List/unfolded"
    (fun () -> 
      let rec loop sum = function
	| [] -> sum
	| a::rest -> loop (operation a sum) rest
      in
      loop 0 int_list |> cont_with_result
    );
  profile_case
    "List/fold_left"
    (fun () ->
      List.fold_left operation 0 int_list |> cont_with_result
    );
  profile_case
    "List/sequence"
    Seq_Prototype.(fun () ->
      let seq = from_list int_list in
      fold operation 0 seq |> cont_with_result
    );
  profile_case
    "List/enum+fold"
    Enumee_Prototype.(fun () ->
      list_enum int_list 0 (fold operation) |> cont_with_result
    );
  profile_case
    "List/s-enum+inline"
    SEnumee_Prototype.(fun () ->
      (list_enum int_list 0 (let rec it a m b cont =
			       cont m (operation a b) it
			     in
			     it) |> cont_with_result)
    );
  profile_case
    "List/iteratee+inline"
    Iteratee_Prototype.(fun () ->
      let rec it i cont a =
	continue cont None it (operation i a)
      in
      Array.enum int_array (fun _ a -> a) it 0
    );
  (* profile_case *)
  (*   "List/unpureit" *)
  (*   UnpureIteratee_Prototype.(fun () -> *)
  (*     enum_list int_list (XCont (ref 0, *)
  (* 				 (fun s -> ref !s), *)
  (* 				 (fun s i it -> *)
  (* 				   s := operation !s i; *)
  (* 				   it), *)
  (* 				 (!))) |> *)
  (* 	  run cont_with_result ignore ignore; *)
  (*   ); *)
  (* profile_case *)
  (*   "List/unpureit-fold" *)
  (*   UnpureIteratee_Prototype.(fun () -> *)
  (*     enum_list' int_list (XCont (ref 0, *)
  (* 				  (fun s -> ref !s), *)
  (* 				  (fun s i it -> *)
  (* 				    s := operation !s i; *)
  (* 				    it), *)
  (* 				  (!))) |> *)
  (* 	  run cont_with_result ignore ignore *)
  (*   ); *)
  (* profile_case *)
  (*   "List/unpureit-from-fold" *)
  (*   UnpureIteratee_Prototype.(fun () -> *)
  (*     enum_from_foldl List.fold_left int_list (XCont (ref 0, *)
  (* 						      (fun s -> ref !s), *)
  (* 						      (fun s i it -> *)
  (* 							s := operation !s i; *)
  (* 							it), *)
  (* 						      (!))) |> *)
  (* 	  run cont_with_result ignore ignore *)
  (*   ); *)
  profile_case
    "List/unpuree+inline"
    Unpuree_Prototype.(fun () ->
      let it =
	SRecur {
	  s=ref 0;
	  cp=(fun s -> s);
	  ex=(!);
	  ret=return;
	  k=fun st el done_k recur ->
	    st := operation !st el;
	    recur
	}
      in
      execute
	~source:(enum_list int_list)
	~query:it
	~on_done:cont_with_result
	());
  profile_case
    "List/unpuree-from-fold"
    Unpuree_Prototype.(fun () ->
      execute
	~source:(enum_list int_list)
	~query:(fold operation 0)
	~on_done:cont_with_result
	());
  ()
