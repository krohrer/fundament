module L = Lazy

exception Empty

type 'a cell =
  | Nil
  | Cons of 'a * 'a t
and 'a t = 'a cell L.t

(*__________________________________________________________________________*)

let nil		= L.from_val Nil
let cons hd tl	= L.from_val (Cons (hd, tl))
let once hd	= cons hd nil

let hd l =
  match L.force l with
  | Cons (h, _)	-> h
  | Nil		-> raise Empty

let tl l =
  match L.force l with
  | Cons (_, t) -> t
  | Nil		-> raise Empty

let is_nil l =
  match L.force l with
  | Nil		-> true
  | Cons _	-> false

let is_cons l =
  match L.force l with
  | Nil		-> false
  | Cons _	-> true

(*__________________________________________________________________________*)

let rec from_thunk th =
  lazy (
    match th () with
    | Some x	-> Cons (x, from_thunk th)
    | None	-> Nil
  )

let from_thunk_exn xterm th =
  let rec cont () =
    match th () with
    | x					-> Cons (x, lazy (cont ()))
    | exception e when e = xterm	-> Nil
  in
  lazy (cont ())

let rec from_thunk_exit th =
  let rec cont () =
    match th () with
    | x			-> Cons (x, lazy (cont ()))
    | exception Exit	-> Nil
  in
  lazy (cont ())

(*__________________________________________________________________________*)

(* let cyclic (x:'a) = *)
(*   let repr = Obj.new_block 0 2 in *)
(*   Obj.set_field repr 0 (Obj.repr x); *)
(*   let c : 'a cell = Obj.obj repr in *)
(*   let l = Lazy.from_val c in *)
(*   Obj.set_field repr 1 (Obj.repr l); *)
(*   l *)

let rec repeat v = lazy (Cons (v, repeat v))

external id : 'a -> 'a = "%identity"

let rec iterate init ?(step=id) ?until () =
  match until with
  | Some term	-> iterate_term init step term
  | None	-> iterate_inf init step
and iterate_inf i f =
  lazy (
    Cons (i, iterate_inf (f i) f)
  )
and iterate_term i f t =
  lazy (
    if i <> t then
      Cons (i, iterate_term (f i) f t)
    else
      Nil
  )

(*__________________________________________________________________________*)

let from_callback cb =
  let rec k x = Cons (x, lazy (cb' x))
  and cb' x = cb k x in
  fun init -> lazy (cb' init)

let from_callback_alt cb init =
  let rec k x = Cons (x, lazy (cb k x))  in
  lazy (cb k init)

let from_callback0 cb =
  let rec k x = Cons (x, lazy (cb k)) in
  lazy (cb k)

(* Slower, but less allocations *)
let from_callback0' cb =
  let rec k x = Cons (x, Lazy.from_fun cb')
  and cb' () = cb k in
  Lazy.from_fun cb'

let from_callback2 cb =
  let rec k x y = Cons (y, lazy (cb' x))
  and cb' x = cb k x in
  fun init -> lazy (cb' init)

let from_callback2' cb =
  let rec k x y = Cons (y, lazy (cb x k)) in
  fun init -> lazy (cb init k)

let rec count_up x ?(step=1) xend =
  lazy (
    if x <= xend then
      Cons (x, count_up (x + step) xend)
    else
      Nil
  )

let rec count_down x ?(step=1) xend =
  lazy (
    if x >= xend then
      Cons (x, count_down (x - step) xend)
    else
      Nil
  )

let rec force n l =
  if n > 0 then
    match L.force l with
    | Nil		-> ()
    | Cons (_,t)	-> force (n-1) t

external from_list : 'a list -> 'a t = "%identity"

let cyclic x =
  let rec l = x :: l in
  from_list l

let from_array ar =
  let n = Array.length ar in
  let rec next i =
    if i < n then
      Cons (ar.(i), lazy (next (i+1)))
    else
      Nil
  in
  lazy (next 0)

(*__________________________________________________________________________*)

let map f =
  let rec recur l =
    match L.force l with
    | Nil -> Nil
    | Cons (x, t) -> Cons (f x, lazy (recur t))
  in
  fun l -> lazy (recur l)

let filter p =
  let rec recur l =
    match L.force l with
    | Nil -> Nil
    | Cons (x, t) when p x -> Cons (x, lazy (recur t))
    | Cons (_, t) -> recur t
  in
  fun l -> lazy (recur l)

let fold f =
  let rec recur a l =
    match L.force l with
    | Nil -> a
    | Cons (x, t) -> recur (f a x) t
  in
  recur

let iter f =
  let rec recur l =
    match L.force l with
    | Nil -> ()
    | Cons (x, t) -> f x; recur t
  in
  recur

let filter_map p f =
  let rec recur l =
    match L.force l with
    | Nil -> Nil
    | Cons (x, t) when p x -> Cons (f x, lazy (recur t))
    | Cons (_, t) -> recur t
  in
  fun l -> lazy (recur l)

let transform f =
  let rec recur l =
    match L.force l with
    | Nil -> Nil
    | Cons (x, t) ->
      (match f x with
      | None -> recur t
      | Some y -> Cons (y, lazy (recur t)))
  in
  fun l -> lazy (recur l)
      

let transform_with_callback cb =
  let rec k l =
    cb k (L.force l)
  in
  fun l -> lazy (k l)

