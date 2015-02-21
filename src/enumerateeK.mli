(** Enumeratees and other stuff for IterateeK module 

    Mostly other stuff for now. Enumeratees are still not very
    intuitive to me. *)

type ('e,'a) t = ('e,'a) IterateeK.t

val map		: ('e->'f) -> ('f,'a) t -> ('e,'a) t

val filter	: ('e->bool) -> ('e,'a) t -> ('e,'a) t
val filter_map	: ('e->'f option) -> ('f,'a) t -> ('e,'a) t

val limit	: int -> ('e,'a) t -> ('e,'e,'a) IterateeK.enumeratee

val iter	: ('e -> unit) -> ('e,unit) t

val fold	: ('a -> 'e -> 'a) -> 'a -> ('e,'a) t
val fold1	: ('a -> 'a -> 'a) -> ('a,'a) t

val one		: ('e,'e) t
val any_of	: ('e->bool) -> ('e,'e) t
val all_of	: ('e->bool) -> ('e,bool) t
val to_list	: ('e,'e list) t

(** Query language *)
(* val execute : *)
(*   source:('el, 'out) EnumeratorK.t -> *)
(*   query:('el,'out) t -> *)
(*   on_done:('out -> 'r) -> *)
(*   ?on_err:(IterateeK.error -> 'r) -> *)
(*   ?on_div:(('el, 'out) t -> 'r) -> *)
(*   unit -> 'r *)

