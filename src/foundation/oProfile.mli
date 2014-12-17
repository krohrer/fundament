type t
type case
type label = string
type measurement = [`allocations | `heap_words | `heap_blocks | `time]

val case : label -> (unit -> 'a) -> case

val comparison	: label -> measurement_list -> t
val singleton	: label -> measurement_list -> t

val run : ?repeat:int -> t -> unit
