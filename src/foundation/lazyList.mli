(** Lazily constructed lists / streams.

    An implementation of lazy lists.
*)

(** Certain operations may throw an [Empty] exception, if the list [is_nil]. *)
exception Empty

(** Cons cell or Nil *)
type 'a cell =
  | Nil
  | Cons of 'a * 'a t
(** Lazy list *)
and 'a t = 'a cell Lazy.t

(** {6 Basic interface} *)
(*__________________________________________________________________________*)

(** Nil *)
val nil : 'a t

(** Singular value *)
val once : 'a -> 'a t

(** Cons *)
val cons : 'a -> 'a t -> 'a t

(** Head of list, may raise [Empty] *)
val hd : 'a t -> 'a
(** Tail of list, may raise [Empty] *)
val tl : 'a t -> 'a t

(** List empty? *)
val is_nil : 'a t -> bool
(** List contains at least one element? *)
val is_cons : 'a t -> bool

(** {6 Generation} *)
(*__________________________________________________________________________*)

(** Infinite lazy list from a single value *)
val repeat : 'a -> 'a t

(** Lazy list from general iterator *)
val iterate : 'a -> ?step:('a -> 'a) -> ?until:'a -> 'a t

(** Lazy list from generator function. *)
val from_thunk : (unit -> 'a option) -> 'a t

(** Lazy list from generator function, stops when exception is thrown *)
val from_thunk_exc : exn -> (unit -> 'a) -> 'a t

(** Efficient lazy list generation using continuations *)
val from_callback : 'a -> ('a -> ('a -> 'a t) -> 'a t) -> 'a t

(** *)
val count_up : int -> ?step:int -> int -> int t

(** *)
val count_down : int -> ?step:int -> int -> int t

