(* Do not use this for [float] until we are sure how ['a array] (used by the
   implementation) special cases those. *)

type 'a t
type index = int

val make : ?cap:int -> unit -> 'a t
val init : int -> (int -> 'a) -> 'a t

val accomodate : index -> 'a t -> unit

val from_callback : ?cap:int -> (('a -> unit) -> index -> unit)-> unit

val compact : 'a t -> unit
val copy : ?compact:bool -> 'a t -> 'a t

val shuffle : rand:(unit -> index) -> 'a t -> unit

val insert : 'a t -> 'a -> index

val set : 'a t -> index -> 'a -> unit
val get : 'a t -> index -> 'a

val swap : 'a t -> index -> index -> unit

val count : 'a t -> int
val capacity : 'a t -> int
