type ('position,'element,'result) t =
  | Done	: 'r -> (_,_,'r) t

  | Error	: 'p option * exn -> ('p,_,_) t

  | Cont	: ('p -> 'e -> ('p,'e,'r) t) -> ('p,'e,'r) t

  | Recur : {
    state	: 's;
    copy	: 's -> 's;
    extract	: 's -> 'r option;
    return	: 'r -> ('p,'e,'r_cont) t;
    k		: 'a. 's -> 'p -> 'e -> ('r -> 'a) -> ('p -> exn -> 'a) -> 'a -> 'a
  } -> (('p,'e,'r_cont) t as 't)

type ('p,'e,'r) enumerator = ('p,'e,'r) t -> ('p,'e,'r) t

type ('po,'eo,'pi,'ei,'r) enumeratee = ('pi,'ei,'r) t -> ('po,'eo,('pi,'ei,'r) t) t

(*__________________________________________________________________________*)

external id : 'a -> 'a = "%identity"

let return o = Done o

let nonterm : _ -> _ option = fun _ -> None

(*__________________________________________________________________________*)

exception Divergence = IterateeK.Divergence

let error p exn = Error (Some p, exn)

let step ~ret_k ~err_k ~cont_k pos elem it =
  match it with
  | Done out		-> ret_k out
  | Error (popt, exn)	-> err_k popt exn
  | Cont k		-> cont_k (k pos elem)
  | Recur r as it	-> cont_k (r.k r.state pos elem r.return error it)
    
let step1 it pos elem =
  match it with
  | Done _
  | Error _ as it	-> it
  | Cont k		-> k pos elem
  | Recur r as it	-> r.k r.state pos elem r.return error it

let rec finish ~ret_k ~err_k ~part_k it =
  match it with
  | Done out		-> ret_k out
  | Error (popt,exn)	-> err_k popt exn
  | Cont k as it	-> part_k it
  | Recur r as it	-> (
    match r.extract r.state with
    | None -> part_k it
    | Some out -> finish ~ret_k ~err_k ~part_k (r.return out)
  )

let error_raise _ x = raise x
let raise_divergence _ = raise Divergence

let finish_exn it =
  finish ~ret_k:id ~err_k:error_raise ~part_k:raise_divergence it

(*__________________________________________________________________________*)

let rec bind it f =
  match it with
  | Done out -> f out

  | Error _ as err -> err

  | Cont k ->
    
    let k p el =
      bind (k p el) f
    in
    Cont k

  | Recur r ->
    
    let return o =
      bind (r.return o) f
    in
    Recur {r with return; state = r.copy r.state}

(*__________________________________________________________________________*)
