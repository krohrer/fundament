type +'a t
type label = string
type probe = [`allocations | `heap_words | `heap_blocks | `time]

val default_probes : probe list

val group : label -> [< `compare|`group] t list -> t
val trial : label -> (unit -> 'a) -> [`trial] t
val compare : label -> ?probe:probe list -> [< `trial] list -> t

val run :
  ?repeat:int ->
  ?fmt:Format.formatter ->
  label ->
  [<`compare|`grou] list -> unit

(* E.g. 

let () = Dynamometer.run ~repeat:10
  "Testing iteration speed of diffenrent constructs"
  [
    comparison "Array" [
      trial "unfolded" (fun () -> ());
      trial "enum+fold" (fun () -> ());
    ];
    comparsion "List" [
      trial "unfolded" (fun () -> ());
      trial "enum+fold" (fun () -> ());
    ];
  ]

*)

