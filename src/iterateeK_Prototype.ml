module type It_Recur =
  sig
    type e
    type s
    type r
    type t
     
    val copy : s -> s
    val extract : s -> r option
    val return : r -> t
    val error : IterateeK.error -> t

    val k : s -> e -> (r->t) -> t -> t
  end

module Limitee (I : It_Recur) : (It_Recur with type e = I.e
					  and  type r = I.t
					  and  type t = (I.e,I.t) IterateeK.t) =
  struct
    type e = I.e
    type r = I.t
    type t = (I.e,I.t) IterateeK.t

    type s = { mutable i : int;
	       n : int; 
	       inns : I.s }

    let copy { i; n; inns } = { i; n; inns = I.copy inns }

    let extract { inns; _ } = IterateeK.SRecur {
      s = inns;
      cp = I.copy;
      ex = I.extract;
      ret = I.return;
      k = I.k
    }

    let return x = I.return x

    let error e = I.error e

    let k s el return recur =
      if s.i < s.n then (
	s.i <- s.i + 1;
	I.k s.inns el return recur
      )
      else (
	recur
      )
  end

module Limit (It : It_Recur) : It_Recur with
					  type e = It.e
					and
					  type r = It.r
					and
					  type t = It.t
  =
  struct
    type e = It.e
    type r = It.r
    type t = It.t

    type s = { mutable i : int;
	       n : int; 
	       inns : It.s }

    let copy { i; n; inns } = { i; n; inns = It.copy inns }

    let extract { inns; _ } = It.extract inns

    let return x = It.return x

    let error e = It.error e

    let k s el return recur =
      if s.i < s.n then (
	s.i <- s.i + 1;
	s.k s.inns el return recur
      )
      else (
	recur
      )
  end
