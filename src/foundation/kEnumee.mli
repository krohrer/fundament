(** Continuation passing style iteratees.

    Keep allocations to a minimum by passing accumulator and state on
    the stack, by using continuation-passing style.

    The state and accumulator types have to be exposed so that this
    can work efficiently.

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

val return : 'o -> ('i,'a,'s,'o) t
val fold : ('a->'b->'a) -> ('b,'a,'s,'a) t

type 'a list_cursor

val array_enumi :
    'i array
    -> 'a
  -> k:('a -> 'o -> unit)
  -> it:('i,'a,'s,'o) t
  -> unit

val list_enumi :
  'i list
  -> k:('o -> unit)
  -> it:('i,'i list_cursor,('a->'o->unit),'o) t
  -> unit
