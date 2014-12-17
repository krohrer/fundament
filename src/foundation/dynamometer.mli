type label = string
type trial
type measurement = [`allocations | `heap_words | `heap_blocks | `time]

val trial : label -> (unit -> 'a) -> trial
val measure : label -> ?repetitions:int -> ?measurements:measurement list -> trial list -> unit
