(* Test IterateeK implementation *)

open IterateeK
open EnumeratorK
open EnumerateeK

let l =
  let rec gen n l =
    if 0 < n then
      gen (n-1) (n::l)
    else
      l
  in
  gen 10 []

let rec it = Cont (fun () ->
  print_endline "Everything is awesome.";
  it)

external id : 'a -> 'a = "%identity"

let it =  Recur { state=();
		  copy=id;
		  extract=nonterm;
		  return;
		  k=(fun s el ret err cont -> err Exit) }

(* Multistaged transformations *)
let _ =
  finish 
    ~ret_k:(Printf.printf "Result = %f\n%!")
    ~err_k:raise
    ~part_k:ignore
  @@ from_list l
  @@ filter (fun i -> i mod 2 = 0)
  @@ map float
  @@ fold (+.) 0.

(* Raise divergence or inner exception if nonterm. *)
let _ =
  let l' =
    finish_exn
    @@ from_list l +++ from_list (List.rev l)
    @@ map float
    @@ to_list
  in
  Printf.printf "Count -> count : %d -> %d \n%!" (List.length l) (List.length l')

(* Divergence *)
let _ =
  try
    finish_exn
    @@ Cont (fun e -> return e)
  with
    Divergence -> Printf.eprintf "Divergent iteratee was expected here.\n%!"
