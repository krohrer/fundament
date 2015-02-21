(** A perverted, unpure form of Oleg's iteratee concept, based on the
    CPS variant.
    
    The iteratee type, with the first two cases very similar to the
    ones from Oleg's paper, plus an additinal case for an impure,
    stateful implementation, and a case for an unrecoverable error. *)
type ('element,'result) t = 

  (** The simplest case, an immediate result *)
  | Done : 'r					->  ( _,'r) t

  (** A captured exception with a position descriptor *)
  | Error : exn -> ( _, _) t

  (** A continuation that consumes one element of the stream *)
  | Cont :  ('e -> ('e,'r) t)			-> ('e,'r) t

  (** A recurring continuation, with copyable state, and a way for the
      [run]-family functions to extract a result at the end of the
      computation based on the last state.  The continuation function
      takes two continuations itself, one for the done case and one
      for the recurrence. *)
  | Recur : {
    (** Internal state*)
    state	: 's;
    (** Copy state *)
    copy	: 's -> 's; 
    (** Extract result from state at end of stream *)
    extract	: 's -> 'r option;
    (** Return/done continuation, used for efficient implementation of
	bind. *)
    return	: 'r -> ('e,'r_cont) t;
    (** Generalized continuation function. *)
    k		: 'a. 's -> 'e-> ('r->'a) -> (exn->'a) -> 'a -> 'a
  } -> ('e,'r_cont) t

(** Polymorphic continuation (contained in record to stay polymorphic) *)
(* and ('s,'el,'b) k = { continuation : 't1 't2 . 's->'el->('b->'t)->'t->(('t1,'t2) t as 't) } *)

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

val nonterm : _ -> _ option

(*__________________________________________________________________________*)

exception Divergence

val error : exn -> (_,_) t

val step :
  ret_k:('r -> 'w) ->
  err_k:(exn -> 'w) -> 
  cont_k:(('e,'r) t -> 'w) ->
  'e -> ('e,'r) t -> 'w

val step1 : ('e,'r) t -> 'e -> ('e,'r) t
  (* To be used in left folds, eg. [ List.fold_left stepl ... [...] ]*)

val finish :
  ret_k:('r -> 'w) ->
  err_k:(exn -> 'w) ->
  part_k:(('e,'r) t -> 'w) ->
  ('e,'r) t -> 'w

val finish_exn : (_,'r) t -> 'r

