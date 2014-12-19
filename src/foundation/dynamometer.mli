type 'a t

and label = string

and 'a thunk = unit -> 'a

and probe


val group : label -> [<`compare|`group] t list -> [`group] t
val trial : label -> 'a thunk -> [`trial] t
val compare : label -> ?seed:bytes -> ?repeat:int -> ?probes:probe list -> [`trial] t list -> [`compare] t


module Probe :
  sig
    type t = probe
      
    val defaults : t list

    val time		: t
    val allocated_words	: t
    val allocated_bytes	: t
    val heap_words	: t
    val heap_blocks	: t
  end

val run :
  ?fmt:Format.formatter ->
  label ->
  [<`compare|`group] list -> unit

(* E.g. 

let () = Dynamometer.run ~repeat:10
  "Testing iteration speed of different constructs"
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

