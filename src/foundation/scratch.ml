module type SEXPR =
  sig
    type t =
      | Atom of string
      | Special of enumerator
      | List of enumerator
    and enumerator = (t,unit) Enumee.t -> unit

    type printer

    val default_printer : printer
    val print : printer -> (t,unit) Enumee.t
  end

(* OCaml is AWESOME! *)
