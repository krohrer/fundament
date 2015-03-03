(** A variant of IterateeK with additional position information

    Useful for iteri, foldi, mapi, parsers, ...

    See IterateeK for further comments, for now.
*)

type ('position,'element,'result) t =
  | Done	: 'r -> (_,_,'r) t

  | Error	: 'p option * exn -> ('p,_,_) t

  | Cont	: ('p -> 'e -> ('p,'e,'r) t) -> ('p,'e,'r) t

  (* Instead of passing ('p*'e) option, we require that there exists a
     sentinel position (for when None is passed). This saves one pair
     allocation per element. *)
  | ContOpt	: ('p -> 'e option -> ('p,'e,'r) t)-> ('p,'e,'r) t

  | Recur : {
    state	: 's;
    copy	: 's -> 's;
    extract	: 's -> 'r option;
    return	: 'r -> ('p,'e,'r_cont) t;
    k		: 'a. 's -> 'p -> 'e -> ('r -> 'a) -> ('p -> exn -> 'a) -> 'a -> 'a
  } -> (('p,'e,'r_cont) t as 't)

type ('p,'e,'r) enumerator = ('p,'e,'r) t -> ('p,'e,'r) t

type ('po,'eo,'pi,'ei,'r) enumeratee = ('pi,'ei,'r) t -> ('po,'eo,('pi,'ei,'r) t) t

(*__________________________________________________________________________*)

val return	: 'a -> (_,_,'a) t
val bind	: ('a,'b,'c) t -> ('c -> ('a,'b,'d) t) -> ('a,'b,'d) t

(*__________________________________________________________________________*)

exception Divergence

val error : 'p -> exn -> ('p,_,_) t

val step :
  ret_k:('r -> 'w) ->
  err_k:('p option -> exn -> 'w) ->
  cont_k:(('p,'e,'r) t -> 'w) ->
  'p -> 'e -> (('p,'e,'r) t as 't) -> 'w

val step1 : ('p,'e,'r) t -> 'p -> 'e -> ('p,'e,'r) t

val finish :
  endp:'p ->
  ret_k:('r -> 'w) ->
  err_k:('p option -> exn -> 'w) ->
  part_k:('t -> 'w) ->
  (('p,_,'r) t as 't) -> 'w

val finish_exn : 'p -> ('p,_,'r) t -> 'r

(*__________________________________________________________________________*)

(* val inject_position : init:'p -> step:('p->'p) -> ('p,'e,'r) t -> ('e,'r) t *)
(* val lift : ('e,'r) t -> ('p,'e,'r) t *)

(*__________________________________________________________________________*)

