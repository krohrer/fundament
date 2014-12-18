type t
type case
type label = string
type measurement = [`allocations | `heap_words | `heap_blocks | `time]

val profile : label -> (unit -> 'a) -> t
val comparison	: label -> measurement list -> t list -> t

val run : ?repeat:int -> ?fmt:Format.formatter -> t list -> unit
