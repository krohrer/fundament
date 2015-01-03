type (_,_,_) t = 
  | Done	: 'b					-> ( _, _,'b) t
  | Cont	: ('a->'t)				-> (('i,'a,'b) t as 't)
  | ICont	: ('i->'a->'t)				-> (('i,'a,'b) t as 't)
  | SCont	: 's * ('s -> 's) * ('s->'a->'t)	-> (('i,'a,'b) t as 't)
  | RCont	: 's * ('s -> 's) * ('s->'a->'t->'t)	-> (('i,'a,'b) t as 't)
  | XCont	: 's * ('s -> 's) * ('s->'a->'t->'t) * ('s->'b)	-> (('i,'a,'b) t as 't)
  | Error	: exn					-> ( _, _, _) t
  | Warning	: exn * 't				-> (( _, _, _) t as 't)

type ('i,'a,'b) enumerator = ('i,'a,'b) t -> ('i,'a,'b) t

(*__________________________________________________________________________*)

let rec run succ_k err_k part_k = function
  | Done o		-> succ_k o
  | Cont _
  | ICont _
  | SCont _
  | RCont _ as it	-> part_k it
  | XCont (s,_,_,f)	-> succ_k (f s)
  | Error x		-> err_k x
  | Warning (x,_)	-> err_k x

let rec copy = function
  | SCont (s,c,k)	-> SCont (c s,c,k)
  | RCont (s,c,k)	-> RCont (c s,c,k)
  | XCont (s,c,k,f)	-> XCont (c s,c,k,f)
  | Done _
  | Cont _
  | ICont _
  | Error _
  | Warning _ as it	-> it

let continue f x = function
  | Cont k			-> f (k x)
  | SCont (s,_,k)		-> f (k s x)
  | RCont (s,_,k) as r		-> f (k s x r)
  | XCont (s,_,k,_) as r	-> f (k s x r)
  | Done _
  | Error _
  | ICont _
  | Warning _ as it		-> it

let continue1 f a x = function
  | Cont k			-> f a (k x)
  | SCont (s,_,k)		-> f a (k s x)
  | RCont (s,_,k) as r		-> f a (k s x r)
  | XCont (s,_,k,_) as r	-> f a (k s x r)
  | Done _
  | Error _
  | ICont _
  | Warning _ as it		-> it

let continue2 f a b x = function
  | Cont k			-> f a b (k x)
  | SCont (s,_,k)		-> f a b (k s x)
  | RCont (s,_,k)	as r	-> f a b (k s x r)
  | XCont (s,_,k,_) as r	-> f a b (k s x r)
  | Done _
  | Error _
  | ICont _
  | Warning _ as it		-> it

let continue3 f a b c x = function
  | Cont k			-> f a b c (k x)
  | SCont (s,_,k)		-> f a b c (k s x)
  | RCont (s,_,k) as r		-> f a b c (k s x r)
  | XCont (s,_,k,_) as r	-> f a b c (k s x r)
  | Done _
  | Error _
  | ICont _
  | Warning _ as it		-> it

let icontinue1 f i x = function
  | Cont k			-> f i (k x)
  | ICont k			-> f i (k i x)
  | SCont (s,_,k)		-> f i (k s x)
  | RCont (s,_,k) as r		-> f i (k s x r)
  | XCont (s,_,k,_) as r	-> f i (k s x r)
  | Done _
  | Error _
  | Warning _ as it		-> it

let icontinue2 f i a x = function
  | Cont k			-> f i a (k x)
  | ICont k			-> f i a (k i x)
  | SCont (s,_,k)		-> f i a (k s x)
  | RCont (s,_,k) as r		-> f i a (k s x r)
  | XCont (s,_,k,_) as r	-> f i a (k s x r)
  | Done _
  | Error _
  | Warning _ as it		-> it

let icontinue3 f i a b x = function
  | Cont k			-> f i a b (k x)
  | ICont k			-> f i a b (k i x)
  | SCont (s,_,k)		-> f i a b (k s x)
  | RCont (s,_,k) as r		-> f i a b (k s x r)
  | XCont (s,_,k,_) as r	-> f i a b (k s x r)
  | Done _
  | Error _
  | Warning _ as it		-> it

let foldx cell it x =
  match it with
  | Cont k			-> k x
  | SCont (s,_,k)		-> k s x
  | RCont (s,_,k) as r		-> k s x r
  | XCont (s,_,k,_) as r	-> k s x r
  | Done _
  | Error _
  | ICont _
  | Warning _ as it		-> cell := it; raise Exit

let ifoldx cell i x = function
  | Cont k			-> k x
  | ICont k			-> k i x
  | SCont (s,_,k)		-> k s x
  | RCont (s,_,k) as r		-> k s x r
  | XCont (s,_,k,_) as r	-> k s x r
  | Done _
  | Error _
  | Warning _ as it		-> cell := it; raise Exit

(*__________________________________________________________________________*)

(* It turns out iteratees form a monad *)

let return o = Done o

(* This is not very efficient because we allocate a lot. Can we
   somehow chain this better? Maybe by explicitly passing a
   continuation for the done case around? *)

(* let rec bind : type b c . (_,'a,b) t -> (b -> ('i,'a,c) t) -> ('i,'a,c) t = fun it itf -> *)
(*   match it with *)
(*   | Done o		-> itf o *)
(*   | Cont k		-> let k x = bind (k x) itf in Cont k *)
(*   | ICont k		-> let k i x = bind (k i x) itf in ICont k *)
(*   | SCont (s,c,k)	-> let k s x = bind (k s x) itf in SCont (s,c,k) *)
(*   | RCont (s,c,k) as r	-> let k s x _ = bind (k s x r) itf in RCont (s,c,k) *)
(*   | XCont (s,c,k,e) as r-> let k s x _ = bind (k s x r) itf in XCont (s,c,k,e) *)
(*   | Error exn		-> Error exn *)
(*   | Warning (exn,itf)	-> Error exn *)

(*__________________________________________________________________________*)

let enum_from_foldl foldl cont it =
  let cell = ref it in
  try foldl (foldx cell) it cont with Exit -> !cell

let enum_string =
  let rec loop str i n it = 
    let i = i + 1 in
    if i < n then
      continue3 loop str i n str.[i] it
    else
      it
  in
  fun s it -> loop s (-1) (String.length s) it

let enum_list =
  let rec loop list it =
    match list with
    | [] -> it
    | x::rest -> continue1 loop rest x it
  in
  loop

let enum_list' list it=
  let cell = ref it in
  try List.fold_left (foldx cell) it list with Exit -> !cell

let enum_array =
  let rec loop arr i n it =
    let i = i + 1 in
    if i < n then
      continue3 loop arr i n arr.(i) it
    else
      it
  in
  fun arr it -> loop arr (-1) (Array.length arr) it

let enum_array' =
  let rec loop arr i n it =
    let i = i + 1 in
    if i < n then
      continue (loop arr i n) arr.(i) it
    else
      it
  in
  fun arr it -> loop arr (-1) (Array.length arr) it

let enumi_string =
  let rec loop i n str it =
    let i = i + 1 in
    if i < n then
      icontinue3 loop i n str str.[i] it
    else
      it
  in
  fun str it -> loop (-1) (String.length str) str it

let enumi_list =
  let rec loop i list it =
    match list with
    | [] -> it
    | x::rest -> icontinue2 loop (i+1) rest x it
  in
  fun list it -> loop (-1) list it

let enumi_array =
  let rec loop i n arr it =
    let i = i + 1 in
    if i < n then
      icontinue3 loop i n arr arr.(i) it
    else
      it
  in
  fun arr it -> loop (-1) (Array.length arr) arr it

let enum_hashtbl tbl it =
    let cell = ref it in
    try Hashtbl.fold (ifoldx cell) tbl it with Exit -> !cell

(*__________________________________________________________________________*)

let getchar = Cont (fun c -> Done c)

let getline =
  let it b c recur =
    if c = '\n' then
      Done (Buffer.contents b)
    else (
      Buffer.add_char b c;
      recur
    )
  in
  let copy b =
    let b' = Buffer.create 80 in
    Buffer.add_buffer b' b;
    b'
  in
  Cont (fun c ->
    let b = Buffer.create 80 in
    it b c (XCont (b, copy, it, Buffer.contents)))

(*__________________________________________________________________________*)

