type k

type ('i,'o,'k) t =
    'i -> ('i,'o,'k) cont -> ('i,'o,'k) stop -> 'k

and ('i,'o,'k) cont =
    ('i,'o,'k) t -> 'k

and ('i,'o,'k) stop =
    'i option -> 'o -> 'k

module Array0 :
  sig
    val enum : 'i array -> 'a -> ('o -> 'a -> unit) -> ('i,'o,'a->unit) t -> unit
  end

module Array2 :
  sig
    type ('i,'o,'k) s
    type index = private int

    val enumi_stop : ('i,'o,'a->index->('i,'o,'k) s->unit as 'k) stop
    val enumi_cont : ('i,'o,'a->index->('i,'o,'k) s->unit as 'k) cont

    val enumi : 'i array -> 'a -> 'k -> ('i,'o,'a->index->('i,'o,'k) s->unit as 'k) t -> unit
  end
