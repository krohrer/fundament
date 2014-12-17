(* This implementation does not special case floats, use [FloatVector] instead. *)

type 'a t
type index = int
type cursor = private index

val make : ?cap:int -> unit -> 'a t
val init : int -> (int -> 'a) -> 'a t

val accomodate : index -> 'a t -> unit

(*__________________________________________________________________________*)

val enum' : ('a->'a,'b) Enumee.t -> 'b t -> 'a -> 'a
val enum1 : (_->'a->'a,'b) Enumee.t -> 'b t -> 'a -> 'a
val enum2 : (_->_->'a->'a,'b) Enumee.t-> 'b t -> 'a -> 'a

val r2enum' : 'b t -> ('a,'b) Enumee.Rec2.t -> 'a -> 'a
val r2enum1 : 'b t -> (_->'a,'b) Enumee.Rec2.t -> 'a -> 'a
val r2enum2 : 'b t -> (_->_->'a,'b) Enumee.Rec2.t -> 'a -> 'a

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
