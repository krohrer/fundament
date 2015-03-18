type ('position,'element,'result) t =
  | Done	: 'r -> (_,_,'r) t
  | Error	: exn -> (_,_,_) t
  | Cont	: ('p -> 'e -> ('p,'e,'r) t) -> ('p,'e,'r) t
  | ContOpt	: (('p*'e) option -> ('p,'e,'r) t)-> ('p,'e,'r) t
  | Recur : {
    state	: 's;
    copy	: 's -> 's;
    extract	: 's -> 'r option;
    return	: 'r -> ('p,'e,'r_cont) t;
    k		: 'a. 's -> 'p -> 'e -> ('r -> 'a) -> (exn -> 'a) -> 'a -> 'a
  } -> (('p,'e,'r_cont) t as 't)

type ('p,'e,'r) enumerator = ('p,'e,'r) t -> ('p,'e,'r) t

type ('po,'eo,'pi,'ei,'r) enumeratee = ('pi,'ei,'r) t -> ('po,'eo,('pi,'ei,'r) t) t

(*__________________________________________________________________________*)

external id : 'a -> 'a = "%identity"

let return o = Done o

let nonterm : _ -> _ option = fun _ -> None

(*__________________________________________________________________________*)

exception Divergence = IterateeK.Divergence

let error exn = Error exn

let step ~ret_k ~err_k ~cont_k pos elem it =
  match it with
  | Done out		-> ret_k out
  | Error exn		-> err_k exn
  | Cont k		-> cont_k (k pos elem)
  | ContOpt k		-> cont_k (k (Some (pos, elem)))
  | Recur r as it	-> cont_k (r.k r.state pos elem r.return error it)
    
let step1 it pos elem =
  match it with
  | Done _
  | Error _ as it	-> it
  | Cont k		-> k pos elem
  | ContOpt k		-> k (Some (pos, elem))
  | Recur r as it	-> r.k r.state pos elem r.return error it

let rec finish ~ret_k ~err_k ~part_k it =
  match it with
  | Done out		-> ret_k out
  | Error exn		-> err_k exn
  | Cont k as it	-> part_k it
  | ContOpt k		-> finish ~ret_k ~err_k ~part_k (k None)
  | Recur r as it	-> (
    match r.extract r.state with
    | None -> part_k it
    | Some out -> finish ~ret_k ~err_k ~part_k (r.return out)
  )

let raise_divergence _ = raise Divergence

let finish_exn it =
  finish ~ret_k:id ~err_k:raise ~part_k:raise_divergence it

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

  | ContOpt k ->
    
    let k p_e_opt =
      bind (k p_e_opt) f
    in
    ContOpt k

  | Recur r ->
    
    let return o =
      bind (r.return o) f
    in
    Recur {r with return; state = r.copy r.state}

let copy = function
  | Done _
  | Error _
  | Cont _
  | ContOpt _ as it	-> it
  | Recur r		-> Recur { r with state = r.copy r.state }

(*__________________________________________________________________________*)

module I = IterateeK

module InjectPosition =
  struct
    type ('p,'s) state = {
      incr		: 'p -> 'p;
      mutable pos	: 'p;
      inner_state	: 's
    }

    let rec make ~pos ~incr = function
      | Done out	-> I.Done out
      | Error exn	-> I.Error exn
      | Cont k		-> I.Cont (fun x -> make ~pos:(incr pos) ~incr (k pos x))
      | ContOpt k	-> I.ContOpt (function
	| None -> make ~pos:(incr pos) ~incr (k None)
	| Some e -> make ~pos:(incr pos) ~incr (k (Some (pos,e))))
      | Recur r	-> 
	let state = { incr; pos; inner_state = r.copy r.state }
	and copy s = { s with inner_state = r.copy r.state }
	and extract s = r.extract s.inner_state in
	let return out = make ~pos:(state.incr state.pos) ~incr:state.incr (r.return out) in
	let k s el ret err cont =
	  let pos = s.pos in
	  let cont' = r.k r.state pos el ret err cont in
	  s.pos <- s.incr s.pos;
	  cont'
	in
	I.Recur { state; copy; extract; return; k }
  end

let inject_position ~pos ~incr = InjectPosition.make ~pos ~incr

let rec discard_position = function
  | I.Done out	-> Done out
  | I.Error exn -> Error exn
  | I.Cont k	-> Cont (fun _ x -> discard_position (k x))
  | I.ContOpt k -> ContOpt (function 
    | None -> discard_position (k None)
    | Some (p,e) -> discard_position (k (Some e)))
  | I.Recur r	-> Recur {
    state = r.copy r.state;
    copy = r.copy;
    extract = r.extract;
    return = (fun out -> discard_position (r.return out));
    k = fun st _ el ret err cont ->
      r.k st el ret err cont
  }


(*__________________________________________________________________________*)
