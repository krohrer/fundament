type ('position,'element,'result) t =
  | Done	: 'r -> (_,_,'r) t

  | Error	: 'p option * exn -> ('p,_,_) t

  | Cont	: ('p -> 'e -> ('p,'e,'r) t) -> ('p,'e,'r) t

  (* | Cont1 : { *)
  (*   extract	: unit -> 'r *)
  (*   k	       	: 'p -> 'e -> 't *)
  (* } -> (('p,'e,'r) t as 't) *)

  | Recur : {
    state	: 's;
    copy	: 's -> 's;
    extract	: 's -> 'r option;
    return	: 'r -> ('p,'e,'r2) t;
    k		: 'a. 's -> 'p -> 'e -> ('r -> 'a) -> ('p -> exn -> 'a) -> 'a -> 'a
  } -> (('p,'e,'r2) t as 't)

type ('p,'e,'r) enumerator = ('p,'e,'r) t -> ('p,'e,'r) t

type ('po,'eo,'pi,'ei,'r) enumeratee = ('pi,'ei,'r) t -> ('po,'eo,('pi,'ei,'r) t) t

(*__________________________________________________________________________*)

val return	: 'a -> (_,_,'a) t
val bind	: ('a,'b,'c) t -> ('c -> ('a,'b,'d) t) -> ('a,'b,'d) t

(*__________________________________________________________________________*)

exception Divergence

val step : fin:('r -> 'w) -> err:('p option -> exn -> 'w) -> cont:('t -> 'w) -> 'p -> 'e -> (('p,'e,'r) t as 't) -> 'w
val step0 : 'p -> 'e -> ('p,'e,'r) t -> ('p,'e,'r) t

val finish : fin:('r -> 'w) -> err:('p option -> exn -> 'w) -> cont:('t -> 'w) -> (('p,_,'r) t as 't) -> 'w
val finish0 : (_,_,'r) t -> 'r

(*__________________________________________________________________________*)
