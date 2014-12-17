(* type ('a,'b,'c) t = continue:'a -> break:'b -> 'c *)

(* Efficient continuation based producers/consumers:

   We are not going to name it iteratees because we are inherently
   stateful.


   element of type 'a
   exposed running variable of type 'b
   result of type 'c
*)
type ('a,'b) producer = cont:('a->'b) -> 'b
type ('a,'b) consumer = cont:('b) -> 'a -> 'b

(* With state, iteratees degenerate to producer/consumers *)
(* Instead of monadic composition, producer/consumers are implemented
   as continuation passing functions, relaxing the typing effort but
   becoming inherently unsafe in the process. meaning that it is now
   up to the programmer to write safe consumers/producers instead of
   composing them.

   The problem has been reformulated from theoretical (purity) to
   practical (performance).

   We need producer and consumers of highter arity if we want to
   efficiently pass more state around.
*)

(* type ('a,'b) producer = continue:('a->'b->'c) -> break:('b->'c) -> 'b -> 'c *)
(* type ('a,'b) producer = continue:('a->'b) -> break:('b) -> 'b *)

(* type ('a,'b) consumer = continue:('b->'c) -> break:('b->'c) -> 'a->'b-> c *)
(* type ('a,'b) consumer = continue:'b -> break:'b -> 'a->'b *)

(* type ('a,'b,'c) transformer = continue:('c->'b) -> break:'b -> 'a->'b *)
(* type ('a,'b,'c) transformer = ('c->'b,'b,'a->'b) t *)

(* E.g. parser *)
(* type ('a,'b,'c) buffered = produce:('c->'b) -> more:'b -> stop:'b -> 'b->'c *)

type ('a,'b) enumee = continue:'a -> 'b -> 'a
type ('a,'b) rec_enumee = (('a,'b) rec_enumee -> 'a) -> 'b -> 'a

module VectorEx :
  sig
    type 'a t
    type index = int
    type cursor = private index

    val enum : ('a->'b t->cursor->'a,'b) enumee -> 'a -> 'b t ->'a
    val rec_enum : ('a->'b t->cursor->'a,'b) rec_enumee -> 'a -> 'b t -> 'a
  end
  =
  struct
    include Vector
    type cursor = index
      
    let enum consumer =
      let rec continue a v c =
	if c < count v then
	  consumer ~continue (get v c) a v (c+1)
	else
	  a
      in
      fun a v -> continue a v 0

    let rec_enum =
      let rec continue re a v c =
	if c < count v then
	  re continue (get v c) a v (c+1)
	else
	  a
      in
      fun consumer a v -> continue consumer a v 0
  end

module ListEx :
  sig
    type 'a t = 'a list

    val enum : ('a->'b t->'a,'b) enumee -> 'a -> 'b t -> 'a
  end
  =
  struct
    type 'a t = 'a list

    let enum consumer =
      let rec continue a = function
	| [] -> a
	| x::r -> consumer ~continue x a r
      in
      fun a -> function
      | [] -> a
      | x::r -> consumer ~continue x a r
  end

module RecEnumee :
  sig
    val fold1 : ('a->'b->'a) -> ('a->_->'a,'b) rec_enumee
  end
  =
  struct
    let fold1 f =
      let rec re continue b a s1 =
	  continue re (f a b) s1
      in
      re
  end

module Enumee :
  sig
    type ('a,'b) t = ('a,'b) enumee

    val fold1 : ('a->'b->'a) -> ('a->_->'a,'b) t
    val fold2 : ('a->'b->'a) -> ('a->_->_->'a,'b) t
    val iter1 : ('b->unit) -> ('a->_->'a,'b) t
    val iter2 : ('b->unit) -> ('a->_->_->'a,'b) t
    val any_of1 : ('b->bool) -> (bool->_->bool,'b) t
    val all_of1 : ('b->bool) -> (bool->_->bool,'b) t
  end
    =
  struct
    type ('a,'b) t = ('a,'b) enumee

    let fold1 f =
      fun ~continue b a s1 ->
	continue (f a b) s1

    let fold2 f =
      fun ~continue b a s1 s2 ->
	continue (f a b) s1 s2

    let iter1 f =
      fun ~continue b a s1 ->
	f b;
	continue a s1

    let iter2 f =
      fun ~continue b a s1 s2 ->
	f b;
	continue a s1 s2

    let any_of1 f =
      fun ~continue b a s1 ->
	if f b then
	  true
	else
	  continue a s1

    let all_of1 f =
      fun ~continue b a s1 ->
	if f b then
	  continue a s1
	else
	  false
  end

(* module type Seq2 = *)
(*   sig *)
(*     val fold : ('a->'b->'a) -> 'a -> ('b,_->_->'a->'a) consumer *)
(*     val iter : ('a->unit) -> ('a,_->_->unit) consumer *)

(*     val any_of : ('a->bool) -> ('a,_->_->bool) consumer *)
(*     val all_of : ('a->bool) -> ('a,_->_->bool) consumer *)
(*     val check : ('a->'b->bool) -> ('a,_->_->'b->bool) consumer *)
(*   end *)

module type S = sig type t = private int val x : t end 
module M : S = struct type t = int let x = 1 end
