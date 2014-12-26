(** A very simple profiler

    Run a closure several times and collect allocation and time
    series. Then print it.
*)

type t
type stats

(*__________________________________________________________________________*)

(** Default profiler *)
val default : t

(** Profile a thunk several times by collecting allocation and time
    stats, possibly labeled. *)
val profile : t -> ?times:int -> (unit -> 'a) -> stats

(** Print collected stats *)
val print_stats : Format.formatter -> string -> stats -> unit
