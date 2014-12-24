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
    type ('i,'k) cursor = { array		: 'i array;
			    count		: int;
			    mutable index	: int;
			    k		: 'k }
  end

type ('i,'k) array_cursor = ('i,'k) Array.cursor

let array_enumi_stop : ('i,'a,('i,'a->'o->unit) array_cursor,'o) stop = fun (type i) (_:i option) a s o ->
    s.Array.k a o

let rec array_enumi_cont : ('i,'a,('a,'o) array_cursor as 's,'o) cont = fun a s it -> 
    Array.(
      let i = s.index in
      s.index <- i + 1;
      if i < s.count then
	(it:('i,'a,'s,'o) t) s.array.(i) a s
	  array_enumi_cont
	  array_enumi_stop
      else
	()
    )

let array_enumi : ( 'i array ->
		    'a ->
		    k:('a->'o->k) ->
		    it:('i,'a,('i,'a->'s->k) array_cursor,'o) t ->
		    unit )
    =
  fun (array:'i array) (a:'a) ~k ~it ->
    Array.(
      let count = Array.length array
      and index = 0 in
      if index < count then
	let cursor = { array;
		       count;
		       index;
		       k } in
	it array.(index) a cursor
	  array_enumi_cont
	  array_enumi_stop
    )

type 'a list_cursor = 'a list

let list_enumi = 
  let rec stop _ a k o =
    k a o
  and cont a k it =
    match a with
    | []	-> ()
    | i::rest	-> it i rest k stop cont
  in
  fun list ~k ~it ->
    cont list k it
  
(* val list_enumi : 'i list -> 'a -> cont:('a -> 'o -> unit) -> ('i,'a,'i list_cursor,'o) t -> unit *)
