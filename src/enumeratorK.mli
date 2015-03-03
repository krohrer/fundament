(** Enumerator module for iteratee implementation in IterateeK *)

type ('el,'a) t = ('el,'a) IterateeK.enumerator

val zero : ('el,'a) t
val (+++) : ('el,'a) t -> ('el,'a) t -> ('el,'a) t

(* val (>>>) : ('a->('el,'b) t) -> ('b->('el,'c) t) -> ('a -> ('el,'c) t) *)

val from_array : 'a array -> ('a,'b) t
val from_list : 'a list -> ('a,'b) t
val from_gen : (unit -> 'a option) -> ('a,'b) t
