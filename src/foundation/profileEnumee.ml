let times = 10
let n = 100000
let burn_cycles = 0

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

(* let op = (+) *)
let op a b = 
  for i = 0 to burn_cycles do
    ignore (a + b)
  done
  ;a + b

let profile_array =
  profile_case "Array/unfolded"
    (fun () ->
      let rec loop arr i n sum =
	if i < n then
	  loop arr (i+1) n (op sum arr.(i))
	else 
	  sum
      in
      loop int_array 0 n 0 |> cont_with_result);
  profile_case "Array/sequence"
    (fun () ->
      let seq = Seq.from_array int_array in
      Seq.fold op 0 seq |> cont_with_result);
  profile_case "Array/unfolded+closure"
    (fun () ->
      let rec loop i sum =
	if i < n then
	  loop (i+1) (op sum int_array.(i))
	else
	  sum
      in
      loop 0 0);
  profile_case "Array/fold_left" 
    (fun () -> Array.fold_left op 0 int_array |> cont_with_result);
  profile_case "Array/enum+fold"
    (fun () -> (Enumee.array_enum int_array 0 (Enumee.fold op) |> cont_with_result));
  profile_case "Array/s-enum+fold"
    (fun () -> (SEnumee.array_enum int_array 0 (SEnumee.fold op) |> cont_with_result));
  profile_case "Array/s-enum+inline"
    (fun () -> (SEnumee.array_enum int_array 0 (let rec it a m b cont = 
						  cont m (op a b) it
						in
						it) |> cont_with_result));
  profile_case "Array/enumi+inline"
    (fun () ->
      let sum = ref 0 in
      let rec it a (i:int) ~cont : int=
	sum := op !sum a;
	cont i ~it
      in
      let _ : int = Enumee.array_enumi int_array (fun i ~cont -> cont i it) in
      !sum |> cont_with_result);
  ()

let profile_list =
  profile_case "List/unfolded"
    (fun () -> 
      let rec loop sum = function
	| [] -> sum
	| a::rest -> loop (op a sum) rest
      in
      loop 0 int_list |> cont_with_result);
  profile_case "List/fold_left"
    (fun () -> List.fold_left op 0 int_list |> cont_with_result);
  profile_case "List/enum+fold"
    (fun () -> (Enumee.list_enum int_list 0 (Enumee.fold op) |> cont_with_result));
  profile_case "List/s-enum+inline"
    (fun () -> (SEnumee.list_enum int_list 0 (let rec it a m b cont =
						cont m (op a b) it
					      in
					      it) |> cont_with_result));
  ()
