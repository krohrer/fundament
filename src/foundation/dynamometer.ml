type t =
  | Group : t list
  | Trial : t list * unit -> 'a
  | Compare of label * 
and label = string
and probe =
  [`allocations | `heap_words | `heap_blocks | `time]
let default_probes =
  [`allocations ; `heap_words ; `heap_blocks ; `time]

let group
