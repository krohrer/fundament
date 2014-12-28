(* Problem: The error happens in the last case from that file *)

(* File "scratch.ml", line 42, characters 2-7: *)
(* Error: Cannot safely evaluate the definition *)
(*        of the recursively-defined module Test2 *)

module rec Test1 :
  sig
    module type S =
      sig
      end

    module type Func = functor () -> sig end

    module Make(F : Func) () : sig end
  end
  =
  Test1

module rec Test2 :
  sig
    module type S =
      sig
      end

    module type Func = functor () -> sig end

    module Make(F : Func) () : sig end
  end
  =
  Test2
