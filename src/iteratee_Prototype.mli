(* A perversion of Oleg's iteratees (sorry!) for better performance in
   OCaml. (Unsupported claim at the moment. double sorry.)

   Not sure what the best way of composition would be.
*)

type ('i,'o,'a) continuations

and ('i,'o,'a) t = 'i -> ('i,'o,'a) continuations -> 'a -> 'a

(*__________________________________________________________________________*)

val continue : ('i,'o,'a) continuations -> exn option -> ('i,'o,'a) t -> 'a -> 'a
val yield : ('i,'o,'a) continuations -> 'i option -> 'o -> 'a -> 'a

(*__________________________________________________________________________*)

(* val zero : 'o -> ('i,'o,'a) t *)

(* val (+++) : ('i,'o as 'i2,'a) t -> ('i2,'o2,'a) t -> ('i,'o2,'a) t *)

(*__________________________________________________________________________*)

(* val run : ('i,'o,'a) t -> ('o -> 'a -> 'a) -> 'a -> 'a *)

(* val seq_list : ('i,'o as 'i2,'a) t list -> ('i2,'o2,'a) t *)

(* val seq : ('i,'o as 'i2, 'a) t (\* Meh. Sleep over it! *\) *)
    
(*__________________________________________________________________________*)

module Array :
  sig
    val enum : 'i array -> ('o->'a->'a) -> ('i,'o,'a) t -> 'a -> 'a
  end

(*__________________________________________________________________________*)

module List :
  sig
    val enum : 'i list -> ('o->'a->'a) -> ('i,'o,'a) t -> 'a -> 'a
  end

(*__________________________________________________________________________*)

module File : 
  sig
    val enum : string -> ('o->'a->'a) -> (char,'o,'a) t -> 'a -> 'a
  end
