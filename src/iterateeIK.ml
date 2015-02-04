type ('position,'element,'result) t =
  | Done	: 'r -> (_,_,'r) t

  | Error	: 'p option * exn -> ('p,_,_) t

  | Cont	: ('p -> 'e -> ('p,'e,'r) t) -> ('p,'e,'r) t

  | Recur : {
    state	: 's;
    copy	: 's -> 's;
    extract	: 's -> 'r option;
    return	: 'r -> ('p,'e,'r2) t;
    k		: 'a. 's -> 'p -> 'e -> ('r -> 'a) -> ('p -> exn -> 'a) -> 'a -> 'a
  } -> (('p,'e,'r2) t as 't)

type ('p,'e,'r) enumerator = ('p,'e,'r) t -> ('p,'e,'r) t

type ('po,'eo,'pi,'ei,'r) enumeratee = ('pi,'ei,'r) t -> ('po,'eo,('pi,'ei,'r) t) t

(*__________________________________________________________________________*)

external id : 'a -> 'a = "%identity"

let return o = Done o

let nonterm : _ -> _ option = fun _ -> None

(*__________________________________________________________________________*)

exception Divergence = IterateeK.Divergence

let error p exn = Error (Some p, exn)

let step
    ~(fin:'r -> 'w)
    ~(err:'p option -> exn -> 'w)
    ~(cont:'t -> 'w)
    pos elem =
  function
  | Done out				-> fin out
  | Error (popt, exn)			-> err popt exn
  | Cont k				-> cont (k pos elem)
  | Recur {state;return;k} as recur	-> cont (k state pos elem return error recur)
  
let step0 pos elem = function
  | Done _
  | Error _ as recur			-> recur
  | Cont k				-> k pos elem
  | Recur {state;return;k} as recur	-> k state pos elem return error recur

let rec finish
    ~(fin:'r -> 'w)
    ~(err:'p option -> exn -> 'w)
    ~(cont:('p,_,'r) t -> 'w) =
  function
  | Done out		-> fin out
  | Error (popt,exn)	-> err popt exn
  | Cont k as it	-> cont it

  | Recur {state;extract;return;_} as it -> (
    match extract state with
    | None -> cont it
    | Some out -> finish ~fin ~err ~cont (return out)
  )

let error_raise _ x = raise x
let raise_divergence _ = raise Divergence

let finish0 it =
  finish ~fin:id ~err:error_raise ~cont:raise_divergence it

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
