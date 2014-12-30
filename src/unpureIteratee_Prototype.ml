type (_,_,_) t = 
  | Done	: 'b					-> ( _, _,'b) t
  | Cont	: ('a->'t)				-> (('i,'a,'b) t as 't)
  | ICont	: ('i->'a->'t)				-> (('i,'a,'b) t as 't)
  | SCont	: 's * ('s->'a->'t)			-> (('i,'a,'b) t as 't)
  | RCont	: 's * ('s->'a->'t->'t)			-> (('i,'a,'b) t as 't)
  | XCont	: 's * ('s->'a->'t->'t) * ('s->'b)	-> (('i,'a,'b) t as 't)
  | Error	: exn					-> ( _, _, _) t
  | Warning	: exn * 't				-> (( _, _, _) t as 't)

type ('i,'a,'b) enumerator = ('i,'a,'b) t -> ('i,'a,'b) t

let run succ_k err_k part_k = function
  | Done o		-> succ_k o
  | Cont _
  | ICont _
  | SCont _
  | RCont _ as it	-> part_k it
  | XCont (s,_,extract)	-> succ_k (extract s)
  | Error x		-> err_k x
  | Warning (x,_)	-> err_k x

let copy it = failwith "TODO"

let continue1 f a x = function
  | Cont k		-> f a (k x)
  | SCont (s,k)		-> f a (k s x)
  | RCont (s,k) as r	-> f a (k s x r)
  | XCont (s,k,_) as r	-> f a (k s x r)
  | it			-> it

let continue2 f a b x = function
  | Cont k		-> f a b (k x)
  | SCont (s,k)		-> f a b (k s x)
  | RCont (s,k)	as r	-> f a b (k s x r)
  | XCont (s,k,_) as r	-> f a b (k s x r)
  | it			-> it

let continue3 f a b c x = function
  | Cont k		-> f a b c (k x)
  | SCont (s,k)		-> f a b c (k s x)
  | RCont (s,k) as r	-> f a b c (k s x r)
  | XCont (s,k,_) as r	-> f a b c (k s x r)
  | it			-> it

let icontinue1 f i x = function
  | Cont k		-> f i (k x)
  | ICont k		-> f i (k i x)
  | SCont (s,k)		-> f i (k s x)
  | RCont (s,k) as r	-> f i (k s x r)
  | XCont (s,k,_) as r	-> f i (k s x r)
  | it			-> it

let icontinue2 f i a x = function
  | Cont k		-> f i a (k x)
  | ICont k		-> f i a (k i x)
  | SCont (s,k)		-> f i a (k s x)
  | RCont (s,k)	as r	-> f i a (k s x r)
  | XCont (s,k,_) as r	-> f i a (k s x r)
  | it			-> it

let icontinue3 f i a b x = function
  | Cont k		-> f i a b (k x)
  | ICont k		-> f i a b (k i x)
  | SCont (s,k)		-> f i a b (k s x)
  | RCont (s,k) as r	-> f i a b (k s x r)
  | XCont (s,k,_) as r	-> f i a b (k s x r)
  | it			-> it

let foldx cell it x =
  match it with
  | Cont k		-> k x
  | SCont (s,k)		-> k s x
  | RCont (s,k) as r	-> k s x r
  | XCont (s,k,_) as r	-> k s x r
  | it			-> cell := it; raise Exit

let ifoldx cell i x = function
  | Cont k		-> k x
  | ICont k		-> k i x
  | SCont (s,k)		-> k s x
  | RCont (s,k) as r	-> k s x r
  | XCont (s,k,_) as r	-> k s x r
  | it			-> cell := it; raise Exit

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
  Cont (fun c ->
    let b = Buffer.create 80 in
    it b c (XCont (b, it, Buffer.contents)))
