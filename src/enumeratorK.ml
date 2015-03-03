type ('el,'a) t = ('el,'a) IterateeK.enumerator

open IterateeK

let zero it = it

let (+++) e1 e2 = fun it ->
  match e1 it with
  | Done _
  | Error _ as it -> it
  | Cont _
  | ContOpt _
  | Recur _ as it -> e2 it

let rec from_list list it =
  match list with
  | [] -> it
  | x::rest ->
    match it with
    | Done _
    | Error _ as it	-> it
    | Cont k		-> from_list rest (k x)
    | ContOpt k		-> from_list rest (k (Some x))
    | Recur r as it	-> from_list rest (r.k r.state x r.return error it)

let rec from_array' arr i n it =
  let i = i + 1 in
  if i < n then
    let x = arr.(i) in
    match it with
    | Done _
    | Error _ as it	-> it
    | Cont k		-> from_array' arr i n (k x)
    | ContOpt k		-> from_array' arr i n (k (Some x))
    | Recur r as it	-> from_array' arr i n (r.k r.state x r.return error it)
  else
    it
      
let from_array arr it =
  from_array' arr (-1) (Array.length arr) it

let rec from_gen g it =
    match g () with
    | None -> it
    | Some x as x_opt ->
      match it with
      | Done _
      | Error _ as it	-> it
      | Cont k		-> from_gen g (k x)
      | ContOpt k	-> from_gen g (k x_opt)
      | Recur r as it	-> from_gen g (r.k r.state x r.return error it)
  
