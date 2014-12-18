type ('a,'m,'b) t = 'a -> 'm -> 'b -> ('a,'m,'b) cont -> 'b
and ('a,'m,'b) cont = 'm -> 'b -> ('a,'m,'b) t -> 'b

let array_enum : 'a array -> 'b -> ('a,int,'b) t -> 'b =
  fun arr ->
    let n = Array.length arr in
    let rec cont i b it =
      if i < n then
	it arr.(i) (i+1) b cont
      else
	b
    in
    fun b it -> cont 0 b it

let array_renum : 'a array -> 'b -> ('a,int,'b) t -> 'b =
  fun arr ->
    let rec cont i b it =
      if i < 0 then
	b
      else
	it arr.(i) (i-1) b cont
    in
    fun b it -> cont (Array.length arr - 1) b it

let list_enum : 'a list -> 'b -> ('a,'a list,'b) t -> 'b =
  let rec cont l b it =
    match l with
    | [] -> b
    | a::rest -> it a rest b cont
  in
  cont

let fold : ('a -> 'b -> 'a) -> ('b,'m,'a) t =
  fun f ->
    let rec it a m b cont = cont m (f b a) it in
    it
