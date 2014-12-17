type ('a,'b) t = continue:'a -> 'b -> 'a

(** If performance is the main goal, maybe it should be like this
    instead:

    val fold2 : ('a->'b->'a) -> (_->_->'a->'a,'b) t

    That way, we can easily write enumerators that do not capture the
    initial 'a
*)
val fold' : ('a->'b->'a) -> ('a->'a,'b) t
val fold1 : ('a->'b->'a) -> (_->'a->'a,'b) t
val fold2 : ('a->'b->'a) -> (_->_->'a->'a,'b) t

val iter' : ('b->unit) -> ('a->'a,'b) t
val iter1 : ('b->unit) -> ('a->_->'a,'b) t
val iter2 : ('b->unit) -> ('a->_->_->'a,'b) t

(* val any_of' : ('b->bool) -> (bool->bool,'b) t *)
(* val any_of1 : ('b->bool) -> (bool->_->bool,'b) t *)
(* val any_of2 : ('b->bool) -> (bool->_->_->bool,'b) t *)

(* val all_of' : ('b->bool) -> (bool->bool,'b) t *)
(* val all_of1 : ('b->bool) -> (bool->_->bool,'b) t *)
(* val all_of2 : ('b->bool) -> (bool->_->_->bool,'b) t *)

module Rec :
  sig
    type ('a,'b) t = continue:(('a,'b) t -> 'a) -> 'b -> 'a

    val fold' : ('a->'b->'a) -> ('a->'a,'b) t
    val fold1 : ('a->'b->'a) -> ('a->_->'a,'b) t
    val fold2 : ('a->'b->'a) -> ('a->_->_->'a,'b) t
    (* val fold3 : ('a->'b->'a) -> ('a->_->_->_->'a,'b) t *)
  end

module Rec2 :
  sig
    type ('a,'b) t = continue:(('a,'b) t -> 'a -> 'a) -> 'b -> 'a

    val iter' : ('b->unit) -> (unit,'b) t
    val iter1 : ('b->unit) -> (_->unit,'b) t
    val iter2 : ('b->unit) -> (_->_->unit,'b) t

    val any_of' : ('a->bool) -> (bool,'a) t
    val any_of1 : ('a->bool) -> (_->bool,'a) t
    val all_of1 : ('a->bool) -> (_->bool,'a) t
  end

