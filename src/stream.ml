(* type 'a stream = *)
(*   | Stream : { *)
(*     s : 's; *)
(*     k : 'r . 'a stream -> ('a -> 'a stream -> 'r) -> ('a stream -> 'r) -> 'r *)
(*   } -> 'a stream *)

(* let from_list_k l = *)
(*   fun stream -> *)
(*     fun cons_k nil_k -> *)
      
(* let from_lazy_list ll = *)
(*   failwith "TODO" *)
