let times = 10
let n = 1000000
let burn_cycles = 10
let op = (+)
(* let op a b = *)
(*   for i = 0 to burn_cycles do *)
(*     ignore (a + b) *)
(*   done *)
(*   ;a + b *)

let profile_case label thunk = Profiler.(
  profile ~times default thunk |> print_stats Format.std_formatter label
)

let int_vector = Vector.init n (fun x -> x)
let int_array = Array.init n (fun x -> x)
let int_list = Array.to_list int_array

let cont_with_result =
  if times = 1 then
    Format.printf "@.@[Result = %d@]@,"
  else 
    ignore

let profile_array =
  profile_case "Array/unfolded"
    (fun () ->
      let rec loop arr i n sum =
	if i < n then
	  loop arr (i+1) n ((+) sum arr.(i))
	else 
	  sum
      in
      loop int_array 0 n 0 |> cont_with_result);
  profile_case "Array/unfolded+closure"
    (fun () ->
      let rec loop i sum =
	if i < n then
	  loop (i+1) ((+) sum int_array.(i))
	else
	  sum
      in
      loop 0 0);
  profile_case "Array/unfolded+closure"
    (fun () ->
      let count = n in
      let arr = int_array in
      let rec loop i sum =
	if i < count then
	  loop (i+1) ((+) sum arr.(i))
	else
	  sum
      in
      loop 0 0);
  profile_case "Array/sequence"
    (fun () ->
      let seq = Seq.from_array int_array in
      Seq.fold (+) 0 seq |> cont_with_result);
  profile_case "Array/fold_left" 
    (fun () -> Array.fold_left (+) 0 int_array |> cont_with_result);
  profile_case "Array/enum+fold"
    (fun () -> (Enumee.array_enum int_array 0 (Enumee.fold (+)) |> cont_with_result));
  profile_case "Array/s-enum+fold"
    (fun () -> (SEnumee.array_enum int_array 0 (SEnumee.fold (+)) |> cont_with_result));
  profile_case "Array/enumi+inline"
    (fun () ->
      let sum = ref 0 in
      let rec it a (i:int) ~cont : int=
	sum := (+) !sum a;
	cont i ~it
      in
      let _ : int = Enumee.array_enumi int_array (fun i ~cont -> cont i it) in
      !sum |> cont_with_result);
  profile_case "Array/s-enum+inline"
    (fun () -> (SEnumee.array_enum int_array 0 (let rec it a m b cont = 
						  cont m ((+) a b) it
						in
						it) |> cont_with_result));
  profile_case "Array/cps-enumi2+linline"
    (fun () -> 
      let rec it i cont stop a s0 s1 =
	cont it ((+) a i) s0 s1
      in
      let k a _ _ =
	cont_with_result a
      in
      CpsEnumee.Array2.enumi int_array 0 k it);
  profile_case "Array/cps_enum+inline"
    (fun () ->
      let rec it i cont stop a =
  	cont it ((+) a i)
      in
      let k _ a =
  	cont_with_result a
      in
      CpsEnumee.Array0.enum int_array 0 k it
    );
  profile_case "Array/iteratee+inline"
    (fun () -> 
      let rec it i cont a =
	Iteratee.continue cont None it ((+) i a)
      in
      Iteratee.Array.enum int_array (fun _ a -> a) it 0
    );
  profile_case "Array/modular-fold"
    ModularIteratee_Prototype.(fun () -> 
      let rec it cont a i = 
	Fold.continue cont it ((+) a i)
      in
      Array.fold it 0 int_array);
  ()

let profile_list =
  profile_case "List/unfolded"
    (fun () -> 
      let rec loop sum = function
	| [] -> sum
	| a::rest -> loop ((+) a sum) rest
      in
      loop 0 int_list |> cont_with_result);
  profile_case "List/fold_left"
    (fun () -> List.fold_left (+) 0 int_list |> cont_with_result);
  profile_case "List/sequence"
    (fun () ->
      let seq = Seq.from_list int_list in
      Seq.fold (+) 0 seq |> cont_with_result);
  profile_case "List/enum+fold"
    (fun () -> (Enumee.list_enum int_list 0 (Enumee.fold (+)) |> cont_with_result));
  profile_case "List/s-enum+inline"
    (fun () -> (SEnumee.list_enum int_list 0 (let rec it a m b cont =
						cont m ((+) a b) it
					      in
					      it) |> cont_with_result));
  profile_case "List/iteratee+inline"
    (fun () ->
      let rec it i cont a =
	Iteratee.continue cont None it ((+) i a)
      in
      Iteratee.Array.enum int_array (fun _ a -> a) it 0);
  ()
