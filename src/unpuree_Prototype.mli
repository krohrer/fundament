(** A perverted, unpure form of Oleg's iteratee concept, based on the
    CPS variant. *)

(** The iteratee type, with the first two cases basically from Oleg's
    paper, an first draft for an impure implementation, and an error
    descriptor. *)
type (_,_) t = 

  (** The simplest case, an immediate result *)
  | Done : 'a					->  ( _,'a) t

  (** A continuation *)
  | Cont :  ('el->('el,'a) t)			-> ('el,'a) t

  (** A configurable, recurring continuation, with copyable state, and
      a way for the [run]-family functions to extract a result at the
      end of the computation based on the last state.  The
      continuation itself takes two contionations itself, one for the
      done case and one for the recurrence. *)
  | SRecur : {
    s	: 's;
    cp	: 's->'s;
    ex	: 's->'b;
    ret : 'b -> ('el,'a) t;
    k	: 't . 's->'el->('b->'t)->'t->'t
  }						-> ('el,'a) t
  (** A captured exception with a position descriptor *)
  | Error : error				-> ( _, _) t

(** An exception which happened at a particular location *)
and error = pos * exn
(** A generic position description*)
and pos = Position.brief Position.t

(** An enumerator is iteration and resource management in one producer. *)
type ('el,'a) enumerator = ('el,'a) t -> ('el,'a) t

(** Directly from Oleg's paper: a producer of the stream eli and a
    consumer of the stream elo *)
type ('elo,'eli,'a) enumeratee = ('eli,'a) t -> ('elo,('eli,'a) t) t

(* In other words: a transformer that takes a consumer of ['eli] into
   a consumer of ['elo] that returns its partial inner iterator at the
   end, so that the computation can continue with another enumeratee.

   Thus sequential composition of two enumeratees is simply their
   concatenation with run:

   e1 >>> e2 = run return (fun e -> Error e) e2 e1
*)
(*__________________________________________________________________________*)

(** {6 Monadic programming, unproven and untested. } *)

val return	: 'a -> (_,'a) t
val bind	: ('e,'a) t -> ('a -> ('e,'b) t) -> ('e,'b) t

(*__________________________________________________________________________*)

(** {6 The usual suspects} *)

val map		: ('e->'f) -> ('f,'a) t -> ('e,'a) t

val filter	: ('e->bool) -> ('e,'a) t -> ('e,'a) t
val filter_map	: ('e->'f option) -> ('f,'a) t -> ('e,'a) t

val iter	: ('e -> unit) -> ('e,unit) t

val fold	: ('a -> 'e -> 'a) -> 'a -> ('e,'a) t
val fold1	: ('a -> 'a -> 'a) -> ('a,'a) t

(*__________________________________________________________________________*)

val enum_array : 'a array -> ('a,'b) t -> ('a,'b) t
val enum_list : 'a list -> ('a,'b) t -> ('a,'b) t

val to_list : ('a,'a list) t

(*__________________________________________________________________________*)

exception Divergence

(** [run done_k exn_k part_k it] *)
val run : ('a -> 'r) -> (error -> 'r) -> ('t -> 'r) -> ((_,'a) t as 't) -> 'r
(** [run it], can additionally raise Divergence upon non-terminated iterator*)
val run0 : (_,unit) t -> unit

(** A more verbose version of [run] *)
val execute :
  source:('el, 'out) enumerator ->
  query:('el,'out) t ->
  on_done:('out -> 'r) ->
  ?on_err:(error -> 'r) ->
  ?on_div:(('el, 'out) t -> 'r) ->
  unit -> 'r

(*__________________________________________________________________________*)

(**/*)

(* val copy : 't -> ((_,_) t as 't) *)

