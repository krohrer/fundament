(*__________________________________________________________________________*)

module Fold =
  struct
    type ('i,'a) it = ('i,'a) cont -> 'a -> 'i -> 'a
    and ('i,'a) cont =
	Cont : 's * ('s -> ('i,'a) cont -> ('i,'a) it -> 'a -> 'a) -> ('i,'a) cont

    let continue (Cont (state, k) as cont) it a =
      k state cont it a

    let run ~it ~state ~continue a i =
      it (Cont (state, continue)) a i

  end

(*__________________________________________________________________________*)

module Iter =
  struct
    type 'i it = 'i cont -> 'i -> unit
    and 'i cont =
	Cont : 's * ('s -> 'i cont -> 'i it -> unit) -> 'i cont

    let continue (Cont (state, k) as cont) it =
      k state cont it

    let run ~it ~state ~continue i =
      it (Cont (state, continue)) i
  end

(*__________________________________________________________________________*)

module Array =
  struct
    type ('i,'a) s =
	{ array		: 'i array;
	  count		: int;
	  mutable index	: int }
	  
    let fold_continue s cont it a =
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
	let state = { array; count; index = 0 }
	and continue = fold_continue in
	Fold.run ~it ~state ~continue a array.(0)
      else
	a

    let iter_continue s cont it =
      let i = s.index + 1 in
      if i < s.count then (
	s.index <- i;
	it cont s.array.(i)
      )

    let iter it array =
      let count = Array.length array in
      if 0 < count then
	let state = { array; count; index = 0 }
	and continue = iter_continue in
	Iter.run ~it ~state ~continue array.(0)
  end
