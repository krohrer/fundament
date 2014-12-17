type ('a,'b,'c) producer = cont:('a->'b->'c) -> brk:('b->'c) -> 'c
type ('a,'b,'c) consumer = 'a -> cont:('b->'c) -> brk:('b->'c) -> 'c
    
module type VECTOR =
  sig
    type 'a t
    type index = int
    type cursor = private index

    val enum : 'a t -> ('a,cursor,unit) consumer -> unit

    val append : 'a t -> ('a,cursor,unit) consumer
  end

module type SEQ =
  sig
    val pipe : ('a,'b) t -> 
  end

(* Write down combinators from paper? *)
