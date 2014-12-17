let profile_case label thunk = Profiler.(
  profile ~times:10 default thunk |> print_stats Format.std_formatter label
)

let n = 1000000
let int_vector = Vector.init n (fun x -> x)
let int_array = Array.init n (fun x -> x)
let int_list = Array.to_list int_array

let profile_array =
  profile_case "fold_left" 
    (fun () -> Array.fold_left (+) 0 int_array);
  profile_case "enum fold"
    (fun () -> (Enumee.array_enum int_array 0 (Enumee.fold (+)) : int));
  profile_case "enumi fold"
    (fun () ->
      let sum = ref 0 in
      let rec it a (i:int) ~cont : int=
	sum := !sum + a;
	cont i ~it
      in
      let _ : int = Enumee.array_enumi int_array (fun i ~cont -> cont i it) in
      !sum);
  ()

let profile_list =
  profile_case "fold_left"
    (fun () -> List.fold_left (+) 0 int_list);
  profile_case "enum fold"
    (fun () -> ());
  ()
