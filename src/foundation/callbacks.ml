(** Continuation passing style higher-order functions *)


(* 'a : running variable, 'e : element to collect, 'c : collected result *)
type ('a,'e,'c) consumer = (cont:('a -> 'e -> unit) -> 'a -> unit) -> 'a -> 'c
(* *)


(* 'a : accumulator, 'e : element to transform, 'c : 'collection to transform *)
type ('a,'e,'c) transformer = (cont:('a -> 'a) -> 'a -> 'e -> 'a) -> 'a -> 'c -> 'a
(* folder, consumer, ... *)


(* 'cur : info about current item
   'inp : one input element for the converter
   'mid : intermediate value
   'out : collected result
*)
(* type ('cur,'inp,'mid,'out) converter =
    k:(kstep:('cur -> 'inp -> 'mid) -> kend:('cur -> 'mid) -> 'out) ->
    'cur -> 'out *)

module LazyListExt =
  struct
    include LazyList

    let produce : ('a,'b,'a cell) Loop.t -> 'a t =
      fun _ -> assert false
  end

module VectorExt =
  struct
    include Vector

    let consume : 'a t -> ('a,'b,'a t) Continuation.Loop.t =
      fun _ -> assert false

    let fold : ('a,'b,'a) Continuation.Loop.t -> 'a -> 'b t -> 'a
      fun _ -> assert false
  end

