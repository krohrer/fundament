type 'a t = unit -> 'a option

let from_array arr =
  let n = ref (Array.length arr) in
  let cur = ref 0 in
    fun () ->
      let i = !cur in
      cur := i + 1;
      if i < !n then
	Some arr.(i)
      else
	None

let from_list list =
  let cur = ref list in
  fun () ->
    match !cur with
    | [] -> None
    | i::rest -> cur := rest; Some i

let fold f =
  let rec loop a seq =
    match seq () with
    | Some b -> loop (f a b) seq
    | None -> a
  in
  loop
