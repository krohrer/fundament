open IterateeK

type ('e,'a) t = ('e,'a) IterateeK.t

external id : 'a -> 'a = "%identity"

(*__________________________________________________________________________*)

let rec map f = function
  | Cont k ->
    
    Cont (fun e -> map f (k (f e)))

  | ContOpt k ->

    let k = function
      | None -> map f (k None)
      | Some e -> map f (k (Some (f e)))
    in

    ContOpt k

  | Recur r ->

    let k s el ret err cont =
      r.k s (f el) ret err cont
    in
    let state = r.copy r.state in
    let return o =
      map f (r.return o)
    in

    Recur { r with state; return; k }

  | Error _
  | Done _ as it -> it  

(*__________________________________________________________________________*)

(* This should probably be a real enumeratee *)
module Limit =
  struct
    (* type ('el,'a) s = { n : int; *)
    (* 			mutable i : int; *)
    (* 			mutable it : ('el,'a) t } *)

    let it n = failwith "TODO"

    (* let copy { i; n; it } = { i; n; it } *)

    (* let rec it n = function *)
    (*   | Cont k		when 0 < 0 -> Cont (fun e -> it (n-1) (k e)) *)
    (*   | SRecur _ as it	when 0 < n ->  *)

    (* 	recur *)
    (* 	  ~state:{ i = n; n; it } *)
    (* 	  ~copy *)
    (* 	  ~extract *)
    (* 	  { continuation } *)

    (*   | Cont _ *)
    (*   | SRecur _ *)
    (*   | Done _ *)
    (*   | Error _ as it -> it *)

    (* and extract { it; _ } = *)
    (*   failwith "TODO" *)
      
    (* and continuation s el return recur = *)
    (*   if 0 < s.i then ( *)
    (* 	s.i <- s.i - 1; *)
    (* 	let it = step0 s.it el in *)
    (* 	if it != s.it then s.it <- it; *)
    (* 	recur *)
    (*   ) *)
    (*   else *)
    (* 	s.it *)
  end

let limit n = Limit.it n

(*__________________________________________________________________________*)

let rec filter pred = function
  | Cont k as it ->

    let k el =
      if pred el then
	filter pred (k el)
      else
	filter pred it
    in
    Cont k

  | ContOpt k as it ->
    
    let k = function
      | None -> filter pred (k None)
      | Some el as e_opt ->
	if pred el then 
	  filter pred (k e_opt)
	else
	  filter pred it
    in

    ContOpt k

  | Recur r ->
    
    let k s el ret err cont =
      if pred el then
	r.k s el ret err cont
      else
	cont
    in
    Recur { r with k }

  | Error _
  | Done _ as it -> it

(*__________________________________________________________________________*)

let rec filter_map f = function
  | Cont k as it ->

    let k el =
      match f el with
      | None	-> filter_map f it
      | Some el' -> filter_map f (k el')
    in
    Cont k

  | ContOpt k as it ->
    
    let k = function
      | None -> filter_map f (k None)
      | Some el ->
	match f el with
	| None -> filter_map f it
	| e_opt -> filter_map f (k e_opt)
    in

    ContOpt k

  | Recur r ->

    let k s el ret err cont =
      match f el with
      | Some el' -> r.k s el' ret err cont
      | None	-> cont
    in
    let return o =
      filter_map f (r.return o)
    in
    Recur { r with return; k }

  | Error _
  | Done _ as it -> it

(*__________________________________________________________________________*)

let to_list =
  let k el =
    let state = ref [el]
    and copy s = ref !s
    and extract s = Some (List.rev !s)
    and k s el _ _ cont =
      s := el :: !s;
      cont
    in
    Recur {state;copy;extract;return;k}
  in
  Cont k

(*__________________________________________________________________________*)

let fold1 f = 
  let k el =
    let state = ref el
    and copy s = ref !s
    and extract s = Some !s
    and k s el _ _ cont =
      s := f !s el;
      cont
    in
    Recur {state;copy;extract;return;k}
  in
  Cont k

(*__________________________________________________________________________*)

let fold f a =
  let state = ref a
  and copy s = s
  and extract s = Some !s
  and k s x _ _ cont =
    s := f !s x;
    cont
  in
  Recur {state;copy;extract;return;k}

(*__________________________________________________________________________*)

let iter f =
  let k el =
    Recur {
      state=();
      copy=id;
      extract=(fun () -> Some ());
      return;
      k=fun s el _ _ cont ->
	f el;
	cont}
  in
  Cont k

(*__________________________________________________________________________*)

let one =
  Cont (fun el -> Done el)

(*__________________________________________________________________________*)

let any_of pred =
  let rec it =
    Cont (fun el -> if pred el then Done el else it)
  in
  it

(*__________________________________________________________________________*)

module All_of =
  struct
    type 'a state = 'a -> bool

    let copy = id

    let extract _ = Some true

    let k pred el ret err cont =
      if pred el then
	cont
      else
	ret false

    let it pred =
      Recur { state = pred; copy; extract; return; k }
  end

let all_of pred = All_of.it pred
