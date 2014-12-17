type ('a,'b) t = 'b -> cont:('a,'b) cont -> 'b
and ('a,'b) cont = 'b -> it:('a -> ('a,'b) t) -> 'b

let fold f =
  let rec it a b ~cont =
    cont (f b a) ~it
  in
  fun init ~cont ->
    cont init ~it

let any_of pred =
  let rec it a b ~cont =
    pred a || cont b ~it
  in
  fun _ ~cont ->
    cont false ~it

let all_of pred =
  let rec it a b ~cont =
    pred a && cont b ~it
  in
  fun _ ~cont ->
    cont true ~it

let iter proc =
  let rec it a () ~cont =
    proc a; cont () ~it
  in
  fun () ~cont ->
    cont () ~it

let array_enum arr =
  let cur = ref 0 in
  let rec cont b ~it =
    let i = !cur in
    cur := i + 1;
    if i < Array.length arr then
      it arr.(i) b ~cont
    else
      b
  in
  fun b it -> it b ~cont

let array_enumi arr =
  let n = Array.length arr in
  let rec cont i ~it =
    if i < n then
      it arr.(i) (i+1) ~cont
    else
      i
  in
  fun it -> it 0 ~cont

let list_enumi l =
  let rec cont l ~it =
    match l with
    | [] -> []
    | a::rest -> it a rest ~cont
  in
  fun it -> it l ~cont

let list_enum l =
  let cur = ref l in
  let rec cont b ~it =
    match !cur with
    | [] -> b
    | a::rest -> cur := rest; it a b ~cont
  in
  fun b it -> it b ~cont

