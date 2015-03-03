(*__________________________________________________________________________*)

type ('element,'result) t = 
  | Done	: 'r -> ( _,'r) t

  | Error	: exn -> ( _, _) t

  | Cont	: ('e -> ('e,'r) t) -> ('e,'r) t

  | ContOpt	: ('e option -> ('e,'r) t) -> ('e,'r) t

  | Recur	: {
    state	: 's;
    copy	: 's -> 's; 
    extract	: 's -> 'r option;
    return	: 'r -> ('e,'r_cont) t;
    k		: 'a. 's -> 'e -> ('r->'a) -> (exn->'a)  -> 'a -> 'a
  } -> ('e,'r_cont) t

type ('el,'a) enumerator = ('el,'a) t -> ('el,'a) t

type ('elo,'eli,'a) enumeratee = ('eli,'a) t -> ('elo,('eli,'a) t) t

(*__________________________________________________________________________*)

external id : 'a -> 'a = "%identity"

let return o = Done o

let nonterm : _ -> _ option = fun _ -> None

(* let recur : *)
(*     state:'s -> *)
(*   ?copy:('s->'s) -> *)
(*   ?extract:('s->'a option) -> *)
(*   ('s,'el,'a) k -> *)
(*   ('el,'a) t *)
(*   = *)
(*   fun *)
(*     ~state *)
(*     ?(copy=id) *)
(*     ?(extract=nonterm) *)
(*     { continuation } *)
(* -> *)
(*   Recur { *)
(*     state; *)
(*     copy; *)
(*     extract; *)
(*     return; *)
(*     k = continuation *)
(*   } *)

(*__________________________________________________________________________*)

(** A partial stream is a Divergence exception when run unless
    otherwise specified. *)
exception Divergence

let error exn = Error exn

let step ~ret_k ~err_k ~cont_k elem it =
  match it with
  | Done out		-> ret_k out
  | Error e		-> err_k e
  | Cont k		-> cont_k (k elem)
  | ContOpt k		-> cont_k (k (Some elem))
  | Recur r as it	-> cont_k (r.k r.state elem r.return error it)

(* let step0 el it = *)
(*   match it with *)
(*   | Done _ *)
(*   | Error _ as it	-> it *)
(*   | Cont k		-> k el *)
(*   | Recur r as it	-> r.k r.state el r.return error it *)

let step1 it el =
  match it with
  | Done _
  | Error _ as it 	-> it
  | Cont k		-> k el
  | ContOpt k		-> k (Some el)
  | Recur r as it	-> r.k r.state el r.return error it

let rec finish ~ret_k ~err_k ~part_k it =
  match it with
  | Done out		-> ret_k out
  | Error err		-> err_k err
  | Cont _ as it	-> part_k it
  | ContOpt k		-> finish ~ret_k ~err_k ~part_k (k None)
  | Recur r as it	-> (
    match r.extract r.state with
    | None -> part_k it
    | Some out -> finish ~ret_k ~err_k ~part_k (r.return out)
  )

let raise_divergence _ = raise Divergence

let finish_exn it = finish ~ret_k:id ~err_k:raise ~part_k:raise_divergence it

(*__________________________________________________________________________*)

let rec bind i fi =
  match i with
  | Done o -> fi o

  | Error _ as it -> it

  | Cont k ->

    let k el =
      bind (k el) fi
    in
    Cont k

  | ContOpt k ->
    
    let k e_opt =
      bind (k e_opt) fi
    in
    ContOpt k

  | Recur r ->

    let return o = bind (r.return o) fi in
    let state = r.copy r.state in

    Recur {r with return; state}

(*__________________________________________________________________________*)
