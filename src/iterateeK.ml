(*__________________________________________________________________________*)

type (_,_) t = 
  | Done : 'a					->  ( _,'a) t

  | Cont :  ('el->('el,'a) t)			-> ('el,'a) t

  | SRecur : {
    s	: 's;
    cp	: 's->'s;
    ex	: ('s->'b) option;
    ret : 'b -> ('el,'a) t;
    k	: 'c 'd . 's->'el->('b->'t)->'t->(('c,'d) t as 't)
  }						-> ('el,'a) t

  | Error : error				-> ( _, _) t

and error = pos * exn
and pos = string

and ('s,'el,'b) k = {
  continuation : 't1 't2 . 's->'el->('b->'t)->'t->(('t1,'t2) t as 't)
}

type ('el,'a) enumerator = ('el,'a) t -> ('el,'a) t

type ('elo,'eli,'a) enumeratee = ('eli,'a) t -> ('elo,('eli,'a) t) t

(*__________________________________________________________________________*)

external id : 'a -> 'a = "%identity"

let return o = Done o

let recur :
    state:'s ->
  ?copy:('s->'s) ->
  ?extract:('s->'a) ->
  ('s,'el,'a) k ->
  ('el,'a) t
  =
  fun
    ~state
    ?(copy=id)
    ?extract
    { continuation }
->
  SRecur {
    s = state;
    cp = copy;
    ex = extract;
    ret = return;
    k = continuation
  }

(*__________________________________________________________________________*)

(** A partial stream is a Divergence exception when run unless
    otherwise specified. *)
exception Divergence

let rec step done_k err_k part_k el = function
  | Done out			-> done_k out
  | Cont k			-> part_k (k el)
  | SRecur {s;ret;k} as it	-> part_k (k s el ret it)
  | Error err			-> err_k err

let rec step0 it el =
  match it with
  | Done _
  | Error _ as it		-> it
  | Cont k			-> k el
  | SRecur {s;ret;k} as it	-> k s el ret it

let rec finish done_k err_k part_k = function
  | Done out			-> done_k out
  | Cont _ as it		-> part_k it
  | SRecur {s;ex=Some ex;ret;_}	-> finish done_k err_k part_k (ret (ex s))
  | SRecur {s;ex=None;_} as it	-> part_k it
  | Error err			-> err_k err

let error_raise (_,exc) = raise exc
let raise_divergence _ = raise Divergence

let finish0 it = finish id error_raise raise_divergence it

(*__________________________________________________________________________*)

let rec bind i fi =
  match i with
  | Cont k ->

    let k el =
      bind (k el) fi
    in
    Cont k

  | SRecur {s;cp;ex;ret;k} ->

    let ret o =
      bind (ret o) fi
    in
    SRecur {s=cp s;cp;ex;ret;k}

  | Done o -> fi o
  | Error _ as it -> it

let propagate_error e = Error e
let propagate_result o = Done o

(*__________________________________________________________________________*)

let copy = function
  | SRecur {s;cp;ex;ret;k} as it ->

    let s' = cp s in
    if s' == s then
      it
    else
      SRecur {s=cp s;cp;ex;ret;k}

  | Done _
  | Cont _
  | Error _ as it -> it
