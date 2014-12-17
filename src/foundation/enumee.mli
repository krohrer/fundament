type ('a,'b) t = 'b -> cont:('a,'b) cont -> 'b
and ('a,'b) cont = 'b -> it:('a -> ('a,'b) t) -> 'b

val array_enum : 'a array -> 'b -> ('a,'b) t -> 'b
val list_enum : 'a list -> 'b -> ('a,'b) t -> 'b

val array_enumi : 'a array -> ('a,int) t -> int
val list_enumi : 'a list -> ('a,'a list) t -> 'a list

val fold : ('a -> 'b -> 'a) -> ('b,'a) t
val any_of : ('a -> bool) -> ('a,bool) t
val all_of : ('a -> bool) -> ('a,bool) t
val iter : ('a -> unit) -> ('a,unit) t

(* val iteri : ('a -> 'b -> unit) -> ('a,'b) t *)
