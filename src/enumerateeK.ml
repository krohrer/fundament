open IterateeK

type ('e,'a) t = ('e,'a) IterateeK.t

external id : 'a -> 'a = "%identity"

(*__________________________________________________________________________*)

let rec map f = function
  | Cont k ->
    
    Cont (fun e -> map f (k (f e)))

  | SRecur {s;cp;ex;ret;k} ->

    let k s el ret cont =
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
  | Done _ as it -> it  

(*__________________________________________________________________________*)

(* This should probably be a real enumeratee *)
module Limit =
  struct
    (* type ('el,'a) s = { n : int; *)
    (* 			mutable i : int; *)
    (* 			mutable it : ('el,'a) t } *)

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

let limit n = failwith "TODO"

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

  | SRecur {s;cp;ex;ret;k} ->
    
    let k s el ret cont =
      if pred el then
	k s el ret cont
      else
	cont
    in
    SRecur {s=cp s;cp;ex;ret;k}

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

  | SRecur {s;cp;ex;ret;k} ->

    let k s el ret cont =
      match f el with
      | Some el' -> k s el' ret cont
      | None	-> cont
    in
    let ret o =
      filter_map f (ret o)
    in
    SRecur {s=cp s;cp;ex;ret;k}

  | Error _
  | Done _ as it -> it

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
    SRecur {s;cp;ex=Some ex;ret;k}
  in
  Cont k

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
    SRecur {s;cp;ex=Some ex;ret;k}
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
  SRecur {s;cp;ex=Some ex;ret;k}

(*__________________________________________________________________________*)

let iter f =
  let k el =
    SRecur {
      s=();
      cp=id;
      ex=Some id;
      ret=(fun () -> Done ());
      k=fun s el _ cont ->
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
    type 'a s = { mutable accum : bool;
		  pred : 'a -> bool }

    let copy { accum; pred } = { accum; pred }

    let extract { accum; _ } = accum

    let continuation s el return recur =
      if s.pred el then
	recur
      else
	return false

    let it pred =
      recur
	~state:{ accum = true; pred }
	~copy
	~extract
	{ continuation }
  end

let all_of pred = All_of.it pred
  
(*__________________________________________________________________________*)

let execute
    ~source
    ~query
    ~on_done
    ?(on_err=(fun (_,exn) -> raise exn))
    ?(on_div=(fun _ -> raise Divergence))
    ()
    =
  finish on_done on_err on_div @@ source @@ query
