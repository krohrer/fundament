module rec Iteratee :
  sig
    type ('a,'b,'c) t = continue:('a -> 'b -> 'c) -> break:('b -> 'c) -> 'c
  end=
  =
  Loop

module LazyListExt =
  struct
    include LazyList

    let c_produce : ('a,'b,'a cell) Loop.t -> 'a t =
      fun _ -> assert false
  end

module VectorExt =
  struct
    include Vector

    let c_consume : 'a t -> ('a,'b,'a t) Loop.t =
      fun _ -> assert false

    let c_fold : ('a,'b,'a) Loop.t -> 'a -> 'b t -> 'a =
      fun _ -> assert false
  end
