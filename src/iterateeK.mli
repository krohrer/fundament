(** A perverted, unpure form of Oleg's iteratee concept, based on the
    CPS variant. *)

(** The iteratee type, with the first two cases very similar to the
    ones from Oleg's paper, plus an additinal case for an impure,
    stateful implementation, and a case for an unrecoverable error. *)
type (_,_) t = 

  (** The simplest case, an immediate result *)
  | Done : 'a					->  ( _,'a) t

  (** A continuation that consumes one element of the stream *)
  | Cont :  ('el->('el,'a) t)			-> ('el,'a) t

  (** A recurring continuation, with copyable state, and a way for the
      [run]-family functions to extract a result at the end of the
      computation based on the last state.  The continuation function
      takes two continuations itself, one for the done case and one
      for the recurrence. *)
  | SRecur : {
    (** Internal state*)
    s	: 's;
    (** Copy state *)
    cp	: 's->'s; 
    (** Extract result from state at end of stream *)
    ex	: ('s->'b) option;
    (** Return/done continuation, used for efficient implementation of
	bind. *)
    ret : 'b -> ('el,'a) t;
    (** Generalized continuation function. *)
    k	: 't1 't2 . 's->'el->('b->'t)->'t->(('t1,'t2) t as 't)
  }						-> ('el,'a) t

  (** A captured exception with a position descriptor *)
  | Error : error				-> ( _, _) t

(** An exception which happened at a particular location *)
and error = pos * exn
(** A generic position description*)
and pos = string

(** Polymorphic continuation (contained in record to stay polymorphic) *)
and ('s,'el,'b) k = { continuation : 't1 't2 . 's->'el->('b->'t)->'t->(('t1,'t2) t as 't) }

(** An enumerator is iteration and resource management in one producer.

    I skipped the monad, because we're unpure anyway.
*)
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

(** Composing enumerators: Kleisli composition specialized for enumerators *)
(* val (>>>) : ('a -> ('el,'b) enumerator) -> ('b -> ('el,'c) enumerator) -> ('a -> ('el,'c) enumerator) *)
(** Appending enumerators *)

(*__________________________________________________________________________*)

val recur :
  state:'s ->
  ?copy:('s->'s) ->
  ?extract:('s->'a) ->
  ('s,'el,'a) k ->
  ('el,'a) t

(*__________________________________________________________________________*)

exception Divergence

(** [step done_k err_k part_k el it] : Feed element el into iterator,
    if possible. *)
val step : ('a -> 'r) -> (error -> 'r) -> ('t -> 'r) -> 'el -> (('el,'a) t as 't) -> 'r
(** [step it el] : An inefficient step function for use with left folds. *)
val step0 : ('el,'a) t -> 'el -> ('el,'a) t

(** [finish done_k err_k part_k it] : Call appropriate continuation. *)
val finish : ('a -> 'r) -> (error -> 'r) -> ('t -> 'r) -> ((_,'a) t as 't) -> 'r
(** [finish it], will raise Divergence on partial iterator. *)
val finish0 : (_,'a) t -> 'a

(**/*)

(* val copy : 't -> ((_,_) t as 't) *)

