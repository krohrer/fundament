type (_,_) t = 
  | Done :
      'out			->  ( _,'out) t
  | Cont :
      ('el->('el,'out) t)	-> ('el,'out) t
  | Recur : {
    k	: 't . 'el->('out->'t)->'t->'t
  }				-> ('el,'out) t
  | SRecur	: {
    s	: 's;
    cp	: 's->'s;
    ex	: 's->'out;
    k	: 't . 's->'el->('out->'t)->'t->'t 
  }				-> ('el,'out) t
  | Error :
      exn			-> ( _, _) t

type ('el,'out) enumerator = ('el,'out) t -> ('el,'out) t

(*__________________________________________________________________________*)

let (>>>) e1 e2 = fun it -> e2 (e1 it)

exception Divergence

let rec run done_k err_k cont_k = function
  | Done o			-> done_k o
  | Cont _
  | Recur _ as it		-> cont_k it
  | SRecur {s;ex;_}		-> done_k (ex s)
  | Error e			-> err_k e

external id : 'a -> 'a = "%identity"

let run_exc it = run id raise ignore it

(*__________________________________________________________________________*)

let copy = function
  | SRecur {s;cp;ex;k} as it	-> let s' = cp s in
				   if s' == s then
				     it
				   else
				     SRecur {s=cp s;cp;ex;k}
  | Recur _
  | Done _
  | Cont _
  | Error _ as it		-> it

(*__________________________________________________________________________*)

let rec map f = function
  | Cont k		-> Cont (fun e -> map f (k (f e)))
  | SRecur {s;cp;ex;k}	-> let k s el done_k recur =
			     k s (f el) done_k recur
			   in
			   SRecur {s=cp s;cp;ex;k}
  | Recur {k}		-> let k el done_k recur =
			     k (f el) done_k recur
			   in
			   Recur {k}
  | Error _
  | Done _ as it	-> it  

(*__________________________________________________________________________*)

let rec filter pred = function
  | Cont k as it	-> Cont (filter_cont_k pred k it)
  | SRecur {s;cp;ex;k}	-> let k s el done_k recur =
			     if pred el then
			       k s el done_k recur
			     else
			       recur
			   in
			   SRecur {s=cp s;cp;ex;k}
  (* This does not work because the type of the state variable would
     escape. But if we inline the function as seen above it works. Is
     this a bug or a restriction in OCaml? *)
  (* | SRecur (s,cp,ex,k)	-> SRecur (cp s,cp,ex, filter_unpure_k pred k) *)
  | Recur {k}		-> let k el done_k recur =
			     if pred el then
			       k el done_k recur
			     else
			       recur
			   in
			     Recur {k}
  | Error _
  | Done _ as it	-> it

and filter_cont_k pred k it =
  fun el ->
    if pred el then
      filter pred (k el)
    else
      filter pred it

let filter_unpure_k : type s . ('e->bool) -> (s->'el->('out->'t)->'t->'t) -> (s->'el->('out->'t)->'t->'t) = fun pred k ->
  let k' : s -> 'el -> ('out->'t) -> 't -> 't = fun s el done_k recur ->
    if pred el then
      k s el done_k recur
    else
      recur
  in
  k'

(*__________________________________________________________________________*)

let rec filter_map f = function
(* : type e f. (e->f option) -> (f,'out) t -> (e,'out) t = fun f -> function *)
  | Cont k as it	-> Cont (filter_map_cont_k f k it)

  | SRecur {s;cp;ex;k}	-> let k s el done_k recur =
			     match f el with
			     | Some el' -> k s el' done_k recur
			     | None -> recur
			   in
			   SRecur {s=cp s;cp;ex;k}

  | Recur {k}		-> let k el done_k recur =
			     match f el with
			     | Some el' -> k el' done_k recur
			     | None -> recur
			   in
			   Recur {k}

  | Error _
  | Done _ as it	-> it

and filter_map_cont_k f k it =
(* : type e f. (e -> f option) -> (f -> (f,'out) t) -> (f,'out) t -> e -> (e,'out) t = fun f k it -> *)
  fun el ->
    match f el with
    | None -> filter_map f it
    | Some el' -> filter_map f (k el')

(*__________________________________________________________________________*)

let to_list =
  let k el =
    let s = ref [el]
    and cp s = ref !s
    and ex s = List.rev !s
    and k s el _ recur =
      s := el :: !s;
      recur
    in
    SRecur {s;cp;ex;k}
  in
    Cont k

let return o = Done o

let rec enum_list list it =
  match list with
  | [] -> it
  | x::rest ->
    match it with
    | Cont k			-> enum_list rest (k x)
    | Recur {k} as it		-> enum_list rest (k x return it)
    | SRecur {s;k;_} as it	-> enum_list rest (k s x return it)
    | Done _
    | Error _ as it	-> it

(*__________________________________________________________________________*)

let fold f a = 
  let k el =
    let s = ref (f a el)
    and cp s = ref !s
    and ex s = !s
    and k s el _ recur =
      s := f !s el;
      recur
    in
    SRecur {s;cp;ex;k}
  in
  Cont k

(*__________________________________________________________________________*)

let iter f =
  let k el =
    SRecur {
      s=();
      cp=id;
      ex=id;
      k=fun s el _ recur ->
	f el;
	recur}
  in
  Cont k

(*__________________________________________________________________________*)

let execute
    ~source
    ~query
    ~on_done
    ?(on_err=raise)
    ?(on_div=fun _ -> raise Divergence)
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

(* Multistaged transformations *)
let _ = 
  run (Printf.printf "Result = %f\n%!") raise ignore
  @@ enum_list l
  @@ filter (fun i -> i mod 2 = 0)
  @@ map float
  @@ fold (+.) 0.

(* A query language using iteratees *)
let _ =
  execute
    ~source:(enum_list l >>> enum_list (List.rev l))
    ~query:(@@ to_list)
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
      
(* From *)
