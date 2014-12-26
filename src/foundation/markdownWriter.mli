type t

val from_formatter : Format.formatter -> t

val zero : t
val plus : t -> t -> t
val list : t list -> t

val title : string -> t
val text : string -> t
val header : string -> t
val li : t list -> t

