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
    type ('i,'o) s = { array	: 'i array;
		       count	: int;
		       k	: 'o -> k }
    type index = int

    let enumi_stop _ _ s o =
      s.k o

    let rec enumi_cont i s it =
      if i < s.count then
	it s.array.(i) (i+1) s enumi_cont enumi_stop 
      else
	()

    let enumi array ~it ~k =
      let count = Array.length array in
      if 0 < count then
	it array.(0) 1 { array; count; k } enumi_cont enumi_stop
  end

module List =
  struct
    type 'i cursor = 'i list

    let enumi_stop _ _ k o =
      k o

    let rec enumi_cont list k it =
      match list with
      | [] -> ()
      | i::rest -> it i rest k enumi_cont enumi_stop

    let enumi list ~it ~k = enumi_cont list k it
  end
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
