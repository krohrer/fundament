type ('i,'o,'a) continuation
and ('i,'o,'a) t = 'i -> ('i,'o,'a) continuation -> 'a -> 'a

val continue : ('i,'o,'a) continuation -> exn option -> ('i,'o,'a) t -> 'a -> 'a
val break : ('i,'o,'a) continuation -> 'i option -> 'o -> 'a -> 'a
    
module Array :
  sig
    val enum : 'i array -> ('o->'a->'a) -> ('i,'o,'a) t -> 'a -> 'a
  end

module List :
  sig
    val enum : 'i list -> ('o->'a->'a) -> ('i,'o,'a) t -> 'a -> 'a
  end

module File : 
  sig
    val enum : string -> ('o->'a->'a) -> (char,'o,'a) t -> 'a -> 'a
  end
