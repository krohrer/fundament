(** A variant of IterateeK with additional position information

    Useful for iteri, foldi, mapi, parsers, ...

    See IterateeK for further comments, for now.
*)

(* Notes for type (_,_,_) t :


*)

type ('position,'element,'result) t =
  | Done	: 'r -> (_,_,'r) t
  | Error	: exn -> (_,_,_) t
  | Cont	: ('p -> 'e -> ('p,'e,'r) t) -> ('p,'e,'r) t
  (* Instead of passing a ('p*'e) option, we use a specialized
     option-like type that can hold an unpacked pair of values,
     saving one indirection at the cost of code duplication /
     specialized option types for tuples. *)
  | ContOpt	: (('p,'e) option2 -> ('p,'e,'r) t)-> ('p,'e,'r) t
  | Recur : {
    state	: 's;
    copy	: 's -> 's;
    extract	: 's -> 'r option;
    return	: 'r -> ('p,'e,'r_cont) t;
    k		: 'a. 's -> 'p -> 'e -> ('r -> 'a) -> (exn -> 'a) -> 'a -> 'a
  } -> (('p,'e,'r_cont) t as 't)

and ('a,'b) option2 = ('a,'b) Option.t2

type ('p,'e,'r) enumerator = ('p,'e,'r) t -> ('p,'e,'r) t

type ('po,'eo,'pi,'ei,'r) enumeratee = ('pi,'ei,'r) t -> ('po,'eo,('pi,'ei,'r) t) t

(*__________________________________________________________________________*)

val return	: 'a -> (_,_,'a) t
val bind	: ('a,'b,'c) t -> ('c -> ('a,'b,'d) t) -> ('a,'b,'d) t

(*__________________________________________________________________________*)

exception Divergence

val error : exn -> ('p,_,_) t

val step :
  ret_k:('r -> 'w) ->
  err_k:(exn -> 'w) ->
  cont_k:(('p,'e,'r) t -> 'w) ->
  'p -> 'e -> (('p,'e,'r) t as 't) -> 'w

val step1 : ('p,'e,'r) t -> 'p -> 'e -> ('p,'e,'r) t

val finish :
  ret_k:('r -> 'w) ->
  err_k:(exn -> 'w) ->
  part_k:('t -> 'w) ->
  (('p,_,'r) t as 't) -> 'w

val finish_exn : ('p,_,'r) t -> 'r

(*__________________________________________________________________________*)

val inject_position : pos:'p -> incr:('p->'p) -> ('p,'e,'r) t -> ('e,'r) IterateeK.t
val discard_position : ('e,'r) IterateeK.t -> ('p,'e,'r) t

(*__________________________________________________________________________*)

