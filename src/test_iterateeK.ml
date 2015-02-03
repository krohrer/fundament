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

let it =  SRecur { s=();
		   cp=id;
		   ex=nonterm;
		   ret=return;
		   k=fun s el ret cont -> Error ("meh", Exit) }

(* Multistaged transformations *)
let _ =
  finish (Printf.printf "Result = %f\n%!") (fun (_,exn) -> raise exn) ignore
  @@ from_list l
  @@ filter (fun i -> i mod 2 = 0)
  @@ map float
  @@ fold (+.) 0.

(* A query language using iteratees *)
let _ =
  execute
    ~source:(from_list l +++ from_list (List.rev l))
    ~query:(map float @@ to_list)
    ~on_done:id
    ()

(* Divergence *)
let _ =
  try
    execute
      ~on_done:id
      ~source:id
      ~query:(Cont (fun e -> return e))
      ()
  with
    Divergence -> Printf.eprintf "Divergent iteratee was expected here.\n%!"
