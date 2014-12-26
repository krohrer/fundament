(* This implementation does not special case floats, use [FloatVector] instead. *)

type 'a t
type index = int

val make : ?cap:int -> unit -> 'a t
val init : int -> (int -> 'a) -> 'a t

val accomodate : index -> 'a t -> unit

(*__________________________________________________________________________*)

val enum : 'a t -> 'b -> ('a,'b) Enumee.t -> 'b

(*__________________________________________________________________________*)

val compact : 'a t -> unit
val copy : ?compact:bool -> 'a t -> 'a t

val shuffle : rand:(unit -> index) -> 'a t -> unit

val insert : 'a t -> 'a -> index

(*__________________________________________________________________________*)

val set : 'a t -> index -> 'a -> unit
val get : 'a t -> index -> 'a

val swap : 'a t -> index -> index -> unit

val count : 'a t -> int
val capacity : 'a t -> int

(*__________________________________________________________________________*)

type 'a printer = Format.formatter -> 'a -> unit
val print : 'a printer -> 'a t printer
