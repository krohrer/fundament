(** Stream folding prototype *)

(* type 'a stream = *)
(*   | Stream : { *)
(*     k : 'r . 'a stream -> ('a -> 'a stream -> 'r) -> ('a stream -> 'r) -> 'r *)
(*   } -> 'a stream *)

(* val from_list : 'a list -> 'a stream *)
(* val from_lazy_list : 'a LazyList.t -> 'a stream *)
