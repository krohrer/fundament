(** Dynamometer: benchmarking the OCaml way.

    - Compare and rank trials of thunks, optionally grouped.
    - Randomized sequence of trials for each repetition.
    - Measure using different probe setups and.
    - Statistics per trial and rankings per comparision.
*)
(*__________________________________________________________________________*)

type 'a t
and group
and trial
and probe

and label = string
and 'a thunk = unit -> 'a

type run_flag =
  | Keep_value_alive_during_gc

module Flags : Set.S with type elt = run_flag

(*__________________________________________________________________________*)

val group : label -> group t list -> group t

val trial : label -> 'a thunk -> trial t

val compare :
  label ->
  ?flags:Flags.t ->
  ?random:Random.State.t ->
  ?repeat:int ->
  ?probes:probe list ->
  trial t list -> group t

val run :
  ?fmt:Format.formatter ->
  title:string ->
  description:string ->
  group t list -> unit

(*__________________________________________________________________________*)

module Probe :
  sig
    type t = probe
      
    val defaults : t list

    val time		: t
    val allocated_words	: t
    val allocated_bytes	: t
    val heap_words	: t
    val heap_blocks	: t
  end

