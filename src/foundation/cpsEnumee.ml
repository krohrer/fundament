type k = unit

type ('i,'o,'k) t =
    'i -> ('i,'o,'k) cont -> ('i,'o,'k) stop -> 'k

and ('i,'o,'k) cont =
    ('i,'o,'k) t -> 'k

and ('i,'o,'k) stop =
    'i option -> 'o -> 'k

module Array0 =
  struct
    let enum array a k it =
      let count = Array.length array in
      let cursor = ref 0 in
      let stop _ o a =
	k o a
      in
      let rec cont it a =
	let i = !cursor in
	if i < count then (
	  cursor := i + 1;
	  it array.(i) cont stop a
	)
      in
      cont it a
  end

module Array2 =
  struct
    type ('i,'o,'k) s = { array : 'i array;
			  count	: int;
			  k	: 'k }
    type index = int

    let enumi_stop iopt o a index s =
      s.k a index s

    let rec enumi_cont it a index s =
      if index < s.count then
	it s.array.(index) enumi_cont enumi_stop a (index+1) s
      else
	()

    let rec enumi array a k it =
      let count = Array.length array in
      if 0 < count then
	it array.(0) enumi_cont enumi_stop a 1 { array; count; k }
      else
	()
  end
