type (_,_) t = 
  | Done :
      'out			->  ( _,'out) t
  | Cont :
      ('el->('el,'out) t)	-> ('el,'out) t
  | Recur : {
    k	: 't . 'el->('out->'t)->'t->'t
  }				-> ('el,'out) t
  | SRecur	: {
    s	: 's;
    cp	: 's->'s;
    ex	: 's->'out;
    k	: 't . 's->'el->('out->'t)->'t->'t 
  }				-> ('el,'out) t
  | Error :
      exn			-> ( _, _) t

(* type ('el,'out) enumerator = ('el,'out) t -> ('el,'out) t *)
(* type ('eli,'elo,'out) enumeratee = ('eli,'out) t -> ('elo,('eli,'out) t) t *)

(*__________________________________________________________________________*)

val return	: 'out -> (_,'out) t

val map		: ('e->'f) -> ('f,'out) t -> ('e,'out) t
val filter	: ('e->bool) -> ('e,'out) t -> ('e,'out) t
val filter_map	: ('e->'f option) -> ('f,'out) t -> ('e,'out) t

val fold	: ('a -> 'e -> 'a) -> 'a -> ('e,'a) t
val iter	: ('e -> unit) -> ('e,unit) t

val run : ('o -> 'r) -> (exn -> 'r) -> ('t -> 'r) -> ((_,'o) t as 't) -> 'r

val enum_list : 'a list -> ('a,'b) t -> ('a,'b) t

val to_list : ('a,'a list) t

(*__________________________________________________________________________*)

val copy : 't -> ((_,_) t as 't)

