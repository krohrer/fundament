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

val cyclic : 'a -> 'a t

(** Infinite lazy list from a single value *)
val repeat : 'a -> 'a t

(** Lazy list from general iterator *)
val iterate : 'a -> ?step:('a -> 'a) -> ?until:'a -> unit -> 'a t

(** Lazy list from generator function *)
val from_thunk : (unit -> 'a option) -> 'a t

(** Lazy list from generator function, list terminates on exception *)
val from_thunk_exn : exn -> (unit -> 'a) -> 'a t

(** Lazy list from generator function, list terminates on Exit exception *)
val from_thunk_exit : (unit -> 'a) -> 'a t

(** Efficient lazy list generation using continuations, these allocate
   slightly more than the [from_thunk] generators, but are usually
   faster. *)

(** *)
val from_callback0	: (('a -> 'a cell) -> 'a cell) -> 'a t

(** *)
val from_callback	: (('a -> 'a cell) -> 'a -> 'a cell) -> 'a -> 'a t

(** *)
val from_callback_alt	: (('a -> 'a cell) -> 'a -> 'a cell) -> 'a -> 'a t

(** *)
val from_callback2	: (('a -> 'b -> 'b cell) -> 'a -> 'b cell) -> 'a -> 'b t

(** Very fast because list representation is subset of lazy list
    representation. *)
val from_list : 'a list -> 'a t

(** *)
val from_array : 'a array -> 'a t

(** Integers *)

(** *)
val count_up : int -> ?step:int -> int -> int t

(** *)
val count_down : int -> ?step:int -> int -> int t

(** {6 Transformation} *)
(*__________________________________________________________________________*)

(** *)
val map : ('a -> 'b) -> 'a t -> 'b t

(** *)
val filter : ('a -> bool) -> 'a t -> 'a t

(** *)
val filter_map : ('a -> bool) -> ('a -> 'b) -> 'a t -> 'b t

(** *)
val transform : ('a -> 'b option) -> 'a t -> 'b t

(** *)
val transform_with_callback : (('a t -> 'b cell) -> 'a cell -> 'b cell) -> 'a t -> 'b t

(** *)
val force : int -> 'a t -> unit

(** {6 } *)
(*__________________________________________________________________________*)

(** *)
val fold : ('a -> 'b -> 'a) -> 'a -> 'b t -> 'a

(** *)
val iter : ('a -> unit) -> 'a t -> unit


