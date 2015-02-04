(** Enumerator module for iteratee implementation in IterateeIK *)

type ('p,'e,'r) t = ('p,'e,'r) IterateeIK.enumerator

val zero : (_,_,_) t
val (+++) : ('p,'e,'r) t -> ('p,'e,'r) t -> ('p,'e,'r) t

(* val (>>>) : ('a->('el,'b) t) -> ('b->('el,'c) t) -> ('a -> ('el,'c) t) *)

val from_array : 'a array -> (int,'a,'b) t
val from_list : 'a list -> (int,'a,'b) t
      
