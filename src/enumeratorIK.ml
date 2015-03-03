type ('p,'e,'r) t = ('p,'e,'r) IterateeIK.enumerator

open IterateeIK

let zero it = it

let (+++) e1 e2 = fun it ->
  match e1 it with
  | Done _
  | Error _ as it	-> it
  | Cont _
  | ContOpt _
  | Recur _ as it	-> e2 it

let rec from_list' list i it =
  match list with
  | [] -> it
  | x::rest ->
    match it with
    | Done _
    | Error _ as it	-> it
    | Cont k		-> from_list' rest (i+1) (k i x)
    | ContOpt k		-> from_list' rest (i+1) (k i (Some x))
    | Recur r as recur	-> from_list' rest (i+1) (r.k r.state i x r.return error recur)

let from_list list it =
  from_list' list 0 it

let rec from_array' arr i n it =
  let i = i + 1 in
  if i < n then
    let x = arr.(i) in
    match it with 
    | Done _
    | Error _ as it	-> it
    | Cont k		-> from_array' arr i n (k i x)
    | ContOpt k		-> from_array' arr i n (k i (Some x))
    | Recur r as recur	-> from_array' arr i n (r.k r.state i x r.return error recur)
  else
    it
      
let from_array arr it =
  from_array' arr (-1) (Array.length arr) it
