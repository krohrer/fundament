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

(* let forever (x:'a) = *)
(*   let repr = Obj.new_block 0 2 in *)
(*   Obj.set_field repr 0 (Obj.repr x); *)
(*   let c : 'a cell = Obj.obj repr in *)
(*   let l = Lazy.from_val c in *)
(*   Obj.set_field repr 1 (Obj.repr l); *)
(*   l *)

let rec from_thunk th =
  lazy (
    match th () with
    | Some x	-> Cons (x, from_thunk th)
    | None	-> Nil
  )

let rec from_thunk_exc xterm th =
  lazy (
    match th () with
    | x		-> Cons (x, from_thunk_exc xterm th)
    | exception e when e = xterm -> Nil
  )

let rec repeat v = lazy (Cons (v, repeat v))

external id : 'a -> 'a = "%identity"

let rec iterate init ?(step=id) ?until =
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

let rec from_callback init callback =
  let rec k x = cons x (cont k x callback)
  and cont k x f = f x k in
  cont k init callback

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
