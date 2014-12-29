module Fold =
  struct
    type ('i,'a) it = ('i,'a) cont -> 'a -> 'i -> 'a
    and ('i,'a) cont =
	Cont : 's * ('s -> ('i,'a) cont -> ('i,'a) it -> 'a -> 'a) -> ('i,'a) cont

    let continue (Cont (state, k) as cont) it a =
      k state cont it a

    let run ~it ~state ~continue a i =
      it (Cont (state, continue)) a i

    module Array =
      struct
	type ('i,'a) s =
	    { array		: 'i array;
	      count		: int;
	      mutable index	: int }
	
	let continue s cont it a =
	  let i = s.index + 1 in
	  if i < s.count then (
	    s.index <- i;
	    it cont a s.array.(i) 
	  )
	  else
	    a

	let fold it a array =
	  let count = Array.length array in
	  if 0 < count then
	    run ~it ~state:{ array; count; index = 0 } ~continue a array.(0)
	  else
	    a
      end
  end
