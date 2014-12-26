type t

type percent = float

val from_float_series	: int -> (int -> float) -> t
val from_int_series	: int -> (int -> int) -> t

val print : Format.formatter -> t -> unit
