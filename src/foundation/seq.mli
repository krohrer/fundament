type 'a t = unit -> 'a option

val from_array : 'a array -> 'a t

val fold : ('a -> 'b -> 'a) -> 'a -> 'b t -> 'a
