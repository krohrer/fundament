type label = string
type trial = Trial : label * (unit -> 'a) -> trial

let trial lbl fn -> Trial (lbl, fn)

(* module Profile = *)
(*   struct *)
(*     open Dynamometer *)
(*     let _ = measure "LazyList generation" ~reps:10 ~gaugues:[`time] *)
(*       [ *)
(* 	"from_callback", (fun () -> *)
(* 	  force n (from_callback *)
(* 		     (fun k x -> k (x +. 1.0)) *)
(* 		     0.0)); *)
(* 	"from_callback0", (fun () -> *)
(* 	  force n (from_callback0 *)
(* 		     (let rx = ref 0.0 in *)
(* 		      fun k -> let x = !rx in *)
(* 			       rx := x +. 1.0; *)
(* 			       k x))); *)
(* 	"from_callback2", (fun () -> *)
(* 	  force n (from_callback2 *)
(* 		     (fun k x -> k (x+1) (float x)) *)
(* 		     0)) *)
(*       ] *)
(*   end *)
    
