type k = unit

type ('i,'a,'s,'o) t =
    'i -> 'a -> 's -> ('i,'a,'s,'o) cont -> ('i,'a,'s,'o) stop -> k

and ('i,'a,'s,'o) cont =
    'a -> 's -> ('i,'a,'s,'o) t -> k

and ('i,'a,'s,'o) stop =
    'i option -> 'a -> 's -> 'o -> k

(*__________________________________________________________________________*)

let return o i a s cont stop =
  stop (Some i) a s o
  
let fold f =
  let rec it b a s cont stop =
    cont (f a b) s it
  in
  it

module Array =
  struct
    include Array
    type ('i,'a,'o) cursor = { array	: 'i array;
			       count	: int;
			       mutable i: int;
			       k	: 'a -> 'o -> k }
  end

type ('i,'a,'o) array_cursor = ('i,'a,'o) Array.cursor

let array_enumi_stop : ('i,'a,('i,'a,'o) array_cursor,'o) stop = fun _ a s o ->
(* let array_enumi_stop _ a s o = *)
    s.Array.k a o

let rec array_enumi_cont : ('i,'a,('i,'a,'o) array_cursor,'o) cont = fun a s it ->
(* let rec array_enumi_cont a s it = *)
    Array.(
      let i = s.i in
      s.i <- i + 1;
      if i < s.count then
	it s.array.(i) a s array_enumi_cont array_enumi_stop
      else
	()
    )

let array_enumi array a ~it ~k =
  Array.(
    let count = Array.length array
    and i = 0 in
    if i < count then
      it
	array.(i)
	a
	{ array; count; i; k }
	array_enumi_cont
	array_enumi_stop
  )

(* type 'a list_cursor = 'a list *)

(* let list_enumi =  *)
(*   let rec stop _ a k o = *)
(*     k a o *)
(*   and cont a k it = *)
(*     match a with *)
(*     | []	-> () *)
(*     | i::rest	-> it i rest k stop cont *)
(*   in *)
(*   fun list ~k ~it -> *)
(*     cont list k it *)
  
(* val list_enumi : 'i list -> 'a -> cont:('a -> 'o -> unit) -> ('i,'a,'i list_cursor,'o) t -> unit *)
