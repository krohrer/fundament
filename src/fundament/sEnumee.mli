type ('a,'m,'b) t =
    'a -> 'm -> 'b -> ('a,'m,'b) cont -> 'b

and ('a,'m,'b) cont =
    'm -> 'b -> ('a,'m,'b) t -> 'b

val array_enum : 'a array -> 'b -> ('a,int,'b) t -> 'b
val array_renum : 'a array -> 'b -> ('a,int,'b) t -> 'b
val list_enum : 'a list -> 'b -> ('a,'a list,'b) t -> 'b

val fold : ('a -> 'b -> 'a) -> ('b,'m,'a) t
