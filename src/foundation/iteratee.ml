type ('i,'o,'a) continuation =
  | Continuation :
      's * 
      ('s -> exn option -> ('i,'o,'a) continuation -> ('i,'o,'a) t -> 'a -> 'a) *
      ('s -> 'i option -> 'o -> 'a -> 'a) ->
    ('i,'o,'a) continuation

and ('i,'o,'a) t = 'i -> ('i,'o,'a) continuation -> 'a -> 'a

let continue (Continuation (s,k,_) as cont) xopt it a =
    k s xopt cont it a

let break (Continuation (s,_,k)) iopt o a =
    k s iopt o a

module Array =
  struct
    type ('i,'o,'a) s =
	{ array		: 'i array;
	  count		: int;
	  mutable index	: int;
	  k		: 'o -> 'a -> 'a }

    let enum_break s _ o a =
      s.k o a

    let rec enum_continue s xopt cont it a =
      let i = s.index + 1 in
      if i < s.count then (
	s.index <- i;
	it s.array.(i) cont a
      )
      else
	a

    let enum array k it a =
      let count = Array.length array in
      if 0 < count then (
	let cont = Continuation ({ array; count; index = 0; k }, enum_continue, enum_break) in
	it array.(0) cont a
      )
      else
	a
  end

module List =
  struct
    type ('i,'o,'a) s =
	{ mutable list : 'i list;
	  k : 'o -> 'a -> 'a }

    let enum_break s _ o a =
      s.k o a

    let rec enum_continue s xopt cont it a =
      match s.list with
      | [] -> a
      | i::rest ->
	s.list <- rest;
	it i cont a

    let rec enum list k it a =
      match list with
      | [] -> a
      | i::rest ->
	let cont = Continuation ({ list = rest; k }, enum_continue, enum_break) in
	it i cont a
  end

module File =
  struct
    type ('o,'a) s =
	{ channel : in_channel;
	  k : 'o -> 'a -> 'a }

    let enum_break s _ o a =
      s.k o a

    let rec enum_continue s xopt cont it a =
      (* Is this tailrecursive? *)
      match input_char s.channel with
      | i -> it i cont a
      | exception End_of_file -> a

    let enum filename k it a =
      let channel = open_in filename in
      try
	let cont = Continuation ({ channel; k }, enum_continue, enum_break) in
	let a = continue cont None it a in
	close_in channel;
	a
      with
      | x -> close_in channel; raise x
  end

(* type ('i,'o,'k) continuation = Continuation : ('i,'o,'s,'k) cont -> ('i,'o,'k) continuation *)

(* and ('i,'o,'s,'k) cont = *)
(*     { state	: 's; *)
(*       continue	: 's -> exn option -> ('i,'o,'k) t -> 'k; *)
(*       yield	: 's -> 'i option -> 'o -> 'k } *)

    (*   's *  *)
    (*   ('s -> exn option -> ('i,'o,'k) t -> 'k) * *)
    (*   ('s -> 'i option -> 'o -> 'k) -> *)
    (* ('i,'o,'k) continuation *)

    (* { state	: 's; *)
    (*   continue	: 's -> exn option -> ('i,'o,'s,'k) t -> 'k; *)
    (*   yield	: 's -> 'i option -> 'o -> 'k; *)
    (*   error	: 's -> exn -> 'k } *)


