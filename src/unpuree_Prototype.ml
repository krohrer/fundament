(*__________________________________________________________________________*)

type (_,_) t = 
  | Done : 'a					->  ( _,'a) t

  | Cont :  ('el->('el,'a) t)			-> ('el,'a) t

  | SRecur : {
    s	: 's;
    cp	: 's->'s;
    ex	: 's->'b;
    ret : 'b -> ('el,'a) t;
    k	: 't . 's->'el->('b->'t)->'t->'t
  }						-> ('el,'a) t

  | Error : error				-> ( _, _) t

and error = pos * exn
and pos = Position.brief Position.t

type ('el,'a) enumerator = ('el,'a) t -> ('el,'a) t

type ('elo,'eli,'a) enumeratee = ('eli,'a) t -> ('elo,('eli,'a) t) t

(*__________________________________________________________________________*)

(** A partial stream is a Divergence exception when run unless
    otherwise specified. *)
exception Divergence

let rec run done_k err_k cont_k = function
  | Done out			-> done_k out
  | Cont _ as it		-> cont_k it
  | SRecur {s;ex;ret;_}		-> run done_k err_k cont_k (ret (ex s))
  | Error err			-> err_k err

external id : 'a -> 'a = "%identity"

let error_raise (_,exc) = raise exc
let raise_divergence _ = raise Divergence

let run_exc it = run id error_raise raise_divergence it

let run0 it = run id error_raise raise_divergence it

(*__________________________________________________________________________*)

(* let (>>>=) e1 e2 = run return  *)
let (>>>) e1 e2 = fun it -> e2 (e1 it)

let return o = Done o

let rec bind i fi =
  match i with
  | Cont k			-> let k el =
				     bind (k el) fi
				   in
				   Cont k
  | SRecur {s;cp;ex;ret;k}	-> let ret o =
				     bind (ret o) fi
				   in
				   SRecur {s=cp s;cp;ex;ret;k}
  | Done o			-> fi o
  | Error _ as it		-> it

(*__________________________________________________________________________*)

(* let copy = function *)
(*   | SRecur {s;cp;ex;ret;k} as it	-> let s' = cp s in *)
(* 					   if s' == s then *)
(* 					     it *)
(* 					   else *)
(* 					     SRecur {s=cp s;cp;ex;ret;k} *)
(*   | Done _ *)
(*   | Cont _ *)
(*   | Error _ as it		-> it *)

(*__________________________________________________________________________*)

let rec map f = function
  | Cont k			-> Cont (fun e -> map f (k (f e)))

  | SRecur {s;cp;ex;ret;k}	-> let k s el ret cont =
  				     k s (f el) ret cont
  				   in
				   let ret o =
				     map f (ret o)
				   in
  				   SRecur {s = cp s;
					   cp;
					   ex;
					   ret;
					   k}

  | Error _
  | Done _ as it	-> it  

(*__________________________________________________________________________*)

(* Does not work, see issues/escapingTypes.ml *)
let filter_srecur_k pred k =
  fun s el ret cont ->
    if pred el then
      k s el ret cont
    else
      cont

let rec filter pred = function
  | Cont k as it	-> let k el =
			     if pred el then
			       filter pred (k el)
			     else
			       filter pred it
			   in
			   Cont k

  | SRecur {s;cp;ex;ret;k}	-> let k s el ret cont =
				     if pred el then
				       k s el ret cont
				     else
				       cont
				   in
				   SRecur {s=cp s;cp;ex;ret;k}

  | Error _
  | Done _ as it	-> it

(*__________________________________________________________________________*)

let rec filter_map f = function
  | Cont k as it		-> let k el =
				     match f el with
				     | None	-> filter_map f it
				     | Some el' -> filter_map f (k el')
				   in
				   Cont k

  | SRecur {s;cp;ex;ret;k}	-> let k s el ret cont =
				     match f el with
				     | Some el' -> k s el' ret cont
				     | None	-> cont
				   in
				   let ret o =
				     filter_map f (ret o)
				   in
				   SRecur {s=cp s;cp;ex;ret;k}

  | Error _
  | Done _ as it	-> it

(*__________________________________________________________________________*)

let to_list =
  let k el =
    let s = ref [el]
    and cp s = ref !s
    and ex s = List.rev !s
    and ret o = return o
    and k s el _ cont =
      s := el :: !s;
      cont
    in
    SRecur {s;cp;ex;ret;k}
  in
    Cont k

let rec enum_list list it =
  match list with
  | [] -> it
  | x::rest ->
    match it with
    | Cont k			-> enum_list rest (k x)
    | SRecur {s;k;ret;_} as it	-> enum_list rest (k s x ret it)
    | Done _
    | Error _ as it		-> it

let rec enum_array' arr i n it =
  let i = i + 1 in
  if i < n then
    match it with 
    | Cont k			-> enum_array' arr i n (k arr.(i))
    | SRecur {s;k;ret;_} as it	-> enum_array' arr i n (k s arr.(i) ret it)
    | Done _
    | Error _ as it		-> it
  else
    it
  
let enum_array arr it =
  enum_array' arr (-1) (Array.length arr) it

(*__________________________________________________________________________*)


let fold1 f = 
  let k el =
    let s = ref el
    and cp s = ref !s
    and ex s = !s
    and ret = return
    and k s el _ cont =
      s := f !s el;
      cont
    in
    SRecur {s;cp;ex;ret;k}
  in
  Cont k

(*__________________________________________________________________________*)

let fold f a =
  let s = ref a
  and cp s = s
  and ex s = !s
  and ret o = Done o
  and k s x _ cont =
    s := f !s x;
    cont
  in
  SRecur {s;cp;ex;ret;k}
  

(*__________________________________________________________________________*)

let iter f =
  let k el =
    SRecur {
      s=();
      cp=id;
      ex=id;
      ret=(fun () -> Done ());
      k=fun s el _ cont ->
	f el;
	cont}
  in
  Cont k

(*__________________________________________________________________________*)

let execute
    ~source
    ~query
    ~on_done
    ?(on_err=error_raise)
    ?(on_div=raise_divergence)
    ()
    =
  run on_done on_err on_div @@ source @@ query

(*__________________________________________________________________________*)

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

(* Multistaged transformations *)
let _ =
  run (Printf.printf "Result = %f\n%!") error_raise ignore
  @@ enum_list l
  @@ filter (fun i -> i mod 2 = 0)
  @@ map float
  @@ fold (+.) 0.

(* A query language using iteratees *)
let _ =
  execute
    ~source:(enum_list l >>> enum_list (List.rev l))
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
      
