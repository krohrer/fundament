type ('i,'o,'a) continuations =
  | Continuations :
      's * 
      ('s -> exn option -> ('i,'o,'a) continuations -> ('i,'o,'a) t -> 'a -> 'a) *
      ('s -> 'i option -> 'o -> 'a -> 'a) ->
    ('i,'o,'a) continuations

and ('i,'o,'a) t = 'i -> ('i,'o,'a) continuations -> 'a -> 'a

(*__________________________________________________________________________*)

let continue (Continuations (s,k,_) as cont) xopt it a =
    k s None cont it a

let yield (Continuations (s,_,k)) iopt o a =
    k s iopt o a

(*__________________________________________________________________________*)

module Array =
  struct
    type ('i,'o,'a) s =
	{ array		: 'i array;
	  count		: int;
	  mutable index	: int;
	  k		: 'o -> 'a -> 'a }

    let enum_yield s _ o a =
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
	let cont = Continuations ({ array; count; index = 0; k }, enum_continue, enum_yield) in
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

    let enum_yield s _ o a =
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
	let cont = Continuations ({ list = rest; k }, enum_continue, enum_yield) in
	it i cont a
  end

module File =
  struct
    type ('o,'a) s =
	{ channel : in_channel;
	  k : 'o -> 'a -> 'a }

    let enum_yield s _ o a =
      s.k o a

    let rec enum_continue s xopt cont it a =
      (* Is this tailrecursive? *)
      match input_char s.channel with
      | i -> it i cont a
      | exception End_of_file -> a

    let enum filename k it a =
      let channel = open_in filename in
      try
	let cont = Continuations ({ channel; k }, enum_continue, enum_yield) in
	let a = continue cont None it a in
	close_in channel;
	a
      with
      | x -> close_in channel; raise x
  end

(* type ('i,'o,'k) continuations = Continuations : ('i,'o,'s,'k) cont -> ('i,'o,'k) continuations *)

(* and ('i,'o,'s,'k) cont = *)
(*     { state	: 's; *)
(*       continue	: 's -> exn option -> ('i,'o,'k) t -> 'k; *)
(*       yield	: 's -> 'i option -> 'o -> 'k } *)

    (*   's *  *)
    (*   ('s -> exn option -> ('i,'o,'k) t -> 'k) * *)
    (*   ('s -> 'i option -> 'o -> 'k) -> *)
    (* ('i,'o,'k) continuations *)

    (* { state	: 's; *)
    (*   continue	: 's -> exn option -> ('i,'o,'s,'k) t -> 'k; *)
    (*   yield	: 's -> 'i option -> 'o -> 'k; *)
    (*   error	: 's -> exn -> 'k } *)


