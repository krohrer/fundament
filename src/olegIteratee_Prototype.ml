module type Monad_Sig =
  sig
    type 'a t
      
    val return : 'a -> 'a t
    val (>>=) : 'a t -> ('a -> 'b t) -> 'b t
  end

module Monad =
  struct
    module type S = Monad_Sig
  end

module type Iteratee_Sig =
  sig
    type 'a m
    type (_,_) t = 
      | Done	: 'o				-> (_,'o) t
      | Cont	: ('i -> ('i,'o) t m)		-> ('i,'o) t
  end

module Iteratee :
  sig
    module type S = Iteratee_Sig
    module Make (M : Monad.S) : S with type 'a m = 'a M.t
  end
  =
  struct
    module type S = Iteratee_Sig
    module Make (M : Monad.S) =
      struct
	type 'a m = 'a M.t
	type (_,_) t = 
	  | Done	: 'o			-> (_,'o) t
	  | Cont	: ('i -> ('i,'o) t m)	-> ('i,'o) t
      end
  end
