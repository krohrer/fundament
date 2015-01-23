type ('el,'a) t = ('el,'a) IterateeK.enumerator

open IterateeK

let zero it = it

let (+++) e1 e2 = fun it ->
  match e1 it with
  | Done _
  | Error _ as it -> it
  | Cont _
  | SRecur _ as it -> e2 it

let rec from_list list it =
  match list with
  | [] -> it
  | x::rest ->
    match it with
    | Cont k			-> from_list rest (k x)
    | SRecur {s;k;ret;_} as it	-> from_list rest (k s x ret it)
    | Done _
    | Error _ as it		-> it

let rec from_array' arr i n it =
  let i = i + 1 in
  if i < n then
    match it with 
    | Cont k			-> from_array' arr i n (k arr.(i))
    | SRecur {s;k;ret;_} as it	-> from_array' arr i n (k s arr.(i) ret it)
    | Done _
    | Error _ as it		-> it
  else
    it
      
let from_array arr it =
  from_array' arr (-1) (Array.length arr) it
