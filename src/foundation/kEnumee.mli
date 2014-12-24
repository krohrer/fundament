(** Continuation passing style iteratees.

    Keep allocations to a minimum by passing accumulator and state on
    the stack, by using continuation-passing style.

    The state and accumulator types have to be exposed so that this
    can work efficiently? At least, if we 

    Also, mutation should be avoided for variables represented as
    blocks in the runtime, so as not to trigger the Gc write
    barrier. (See list_enumi)
    Although with that last point, I am not for certain. *)

type k

type ('i,'a,'s,'o) t =
    'i -> 'a -> 's -> ('i,'a,'s,'o) cont -> ('i,'a,'s,'o) stop -> k

and ('i,'a,'s,'o) cont =
    'a -> 's -> ('i,'a,'s,'o) t -> k

and ('i,'a,'s,'o) stop =
    'i option -> 'a -> 's -> 'o -> k

(*__________________________________________________________________________*)

val return : 'o -> ('i,'a,'s,'o) t
val fold : ('a->'b->'a) -> ('b,'a,'s,'a) t

(*__________________________________________________________________________*)

module Array :
  sig
    type ('i,'o) s
    type index = private int

    val enumi_stop : ('i,index,('i,'o) s,'o) stop
    val enumi_cont : ('i,index,('i,'o) s,'o) cont
    val enumi : 'i array -> it:('i,index,('i,'o) s,'o) t -> k:('o -> unit) -> unit
  end

(*__________________________________________________________________________*)

module List :
  sig
    type 'i cursor = private 'i list

    val enumi : 'i list -> it:('i,'i cursor,'k,'o) t -> k:('o -> unit as 'k) -> unit
  end
