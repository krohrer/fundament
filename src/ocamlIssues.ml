(* Problem: Escaping types *)

(* Error: This expression has type s#0 but an expression was expected of type *)
(*          s#0 *)
(*        The type constructor s#0 would escape its scope *)

type t =
  | Id : ('a->'a) -> t (* The type variable 'a is not universally quantified, I think. *)

let run : 'a -> t -> 'a =  fun x -> function
  | Id id -> id x

(* Workaround since OCaml 4.03: *)

type t =
  | Id : { id : 'a . 'a -> 'a } -> t

let run : 'a -> t -> 'a = fun x -> function
  | Id { id } -> id x


(*__________________________________________________________________________*)

(* Problem: The error happens in the last case from that file, which
   can be confusing. *)

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
