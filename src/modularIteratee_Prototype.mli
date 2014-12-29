(*__________________________________________________________________________*)

module Fold :
  sig
    type ('i,'a) cont
    type ('i,'a) it = ('i,'a) cont -> 'a -> 'i -> 'a

    val continue : ('i,'a) cont -> ('i,'a) it -> 'a -> 'a

    val run :
      it:('i,'a) it ->
      state:'s ->
      continue:('s -> ('i,'a) cont -> ('i,'a) it -> 'a -> 'a) ->
      'a -> 'i -> 'a

    module Array :
      sig
	val fold : ('i,'a) it -> 'a -> 'i array -> 'a
      end
  end

(*__________________________________________________________________________*)

(* module Enumee = *)
(*   struct *)
(*     module type K = *)
(*       sig *)
(* 	type iteratee *)

(* 	val continue : iteratee -> unit *)
(*       end *)

(*     type 'it k = (module K with type iteratee = 'it) *)
	
(*     type ('i,'s) t = 'i -> 's -> (('i,'s) t as 'it) k -> unit *)
(*   end *)

(* (\*__________________________________________________________________________*\) *)

(* module type Parser = *)
(*   sig *)
(*     type t *)
(*     type input *)
(*     type output *)
(*     type iteratee *)
(*     type error *)
      
(*     val continue : iteratee -> exn option -> t *)
(*     val yield : input option -> output -> t *)
(*   end *)

(* (\*__________________________________________________________________________*\) *)
(* (\* I am now convinced that this is a dead end. *\) *)

(* module ArrayIt : *)
(*   sig *)
(*     val fold : 'i array -> ('i,'a) Foldee.t -> 'a -> 'a *)
(*     val enum : 'i array -> 's -> ('i,'s) Enumee.t -> unit *)
(*   end *)
(*   = *)
(*   struct *)
(*     let fold (type i) (type a) (array:i array) (foldee:(i,a) Foldee.t as 'it) (a:a) = *)
(*       (\* How can we write a module of type Foldee.K? *\) *)
(*       let k : (i,(i,a) Foldee.t) Foldee.k = *)
(* 	let module rec K = *)
(* 	      struct *)
(* 		type accum = a *)
(* 		type iteratee = (i,a) Foldee.t *)

(* 		let array = array *)
(* 		let count = Array.length array *)
(* 		let cursor = ref 1 *)

(* 		let continue it a = *)
(* 		  let i = !count in *)
(* 		  if i < count then ( *)
(* 		    count := i + 1; *)
(* 		    it array.(i) c *)
(* 		  ) *)
(* 	      end *)
(* 	in *)
(* 	(module K) *)
(*       in *)
(*       a *)

(*     let enum array state enumee = *)
(*       failwith "TODO" *)
(*   end *)

(* (\*__________________________________________________________________________*\) *)

(* module rec K : *)

(* module type rec S = *)
(*   sig *)
(*     val m : (module S) *)
(*   end *)
(* ;; *)

(* module rec M : *)
(*   sig *)
(*     val m : (module S *)
(*   end *)
(*   = *)
(*   struct *)
(*     let m = (module M : S) *)
(*   end *)
(* ;; *)

(* (\*__________________________________________________________________________*\) *)
