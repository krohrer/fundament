type ('position,'element,'result) t =
  | Done	: 'r -> (_,_,'r) t

  | Error	: 'p option * exn -> ('p,_,_) t

  | Cont	: ('p -> 'e -> ('p,'e,'r) t) -> ('p,'e,'r) t

  | Cont1 : {
    k1	       	: 'p -> 'e -> 't;
    k0		: 'r -> 't
  } -> (('p,'e,'r) t as 't) 

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

(*let recur*)

(*__________________________________________________________________________*)

exception Divergence = IterateeK.Divergence

let error p exn = Error (Some p, exn)

let step
    ~(fin:'r -> 'w)
    ~(err:'p -> exn -> 'w)
    ~(cont:'t -> 'w)
    pos elem = function
    | Done out		-> fin out
    | Error (popt, exn) -> err popt exn
    | Cont k		-> cont (k pos elem)
    | Cont1 {k1;_}	-> k1 pos elem
    | Recur {state;return;k} as recur
      			-> cont (k state pos elem return error recur)
  
let step0 pos elem = function
  | Done _
  | Error _ as recur	-> recur
  | Cont k		-> k pos elem
  | Cont1 {k1;_}	-> k1 pos elem
  | Recur {state;return;k} as recur
			-> k state pos elem return error recur
(* val finish : fin:('r -> 'w) -> err:('p option -> exn -> 'w) -> cont:('t -> 'w) -> ((_,_,'r) t as 't) -> 'w *)
(* val finish0 : (_,_,'r) t -> 'r *)

(*__________________________________________________________________________*)
