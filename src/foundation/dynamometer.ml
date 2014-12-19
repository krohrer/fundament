(*__________________________________________________________________________*)

module Probe =
  struct
    type t =
      | Memory of (gc0:Gc.stat -> gc1:Gc.stat -> float)
      | Time

    let bytes_per_word = Sys.word_size / 8

    let allocated_words_probe ~gc0 ~gc1 =
      Gc.(gc1.minor_words +. gc1.major_words -. gc1.promoted_words) -.
      Gc.(gc0.minor_words +. gc0.major_words -. gc0.promoted_words)

    let allocated_bytes_probe ~gc0 ~gc1 =
      float bytes_per_word *. (allocated_words_probe ~gc0 ~gc1)

    let heap_words_probe ~gc0 ~gc1 =
      float Gc.(gc1.live_words - gc0.live_words)

    let heap_blocks_probe ~gc0 ~gc1 =
      float Gc.(gc1.live_blocks - gc0.live_blocks)

    let time		= Time
    let allocated_words = Memory allocated_words_probe
    let allocated_bytes = Memory allocated_bytes_probe
    let heap_words	= Memory heap_words_probe
    let heap_blocks	= Memory heap_blocks_probe

    let defaults = [ time;
		     allocated_bytes;
		     heap_words;
		     heap_blocks ]
  end

(*__________________________________________________________________________*)

type 'a t =
  | Trial	: label * 'a thunk -> [`trial] t
  | Compare	: label * compare -> [`compare] t
  | Group	: label * [<`compare|`group] t list -> [`group] t

and label = string

and 'a thunk = unit -> 'a

and measurement =
  | MeasureMemory	of (Gc.stat -> Gc.stat -> float) * float array
  | MeasureTime		of float array

and compare =
    { random	: Random.State.t;
      repeat	: int;
      probes	: probe array;
      trials	: [`trial] t array; 
      ranking	: int array;
      stats	: Stats.t option array;
      measurements	: trial:int -> probe:int -> float array }

and probe = Probe.t

(*__________________________________________________________________________*)

let trial label thunk = Trial (label, thunk)

let compare label ?random ?(repeat=1) ?(probes=Probe.defaults) trials =
  let random =
    match random with
    | None	-> Random.State.make_self_init ()
    | Some r	-> r
  in
  Compare (label, {
    random;
    repeat;
    probes = Array.of_list probes;
    trials = Array.of_list trials;
    ranking = Array.make repeat (-1);
    stats = Array.make repeat None;
    measurements = fun ~trial ~probe -> assert false
  })

let group =
  fun label list -> Group (label, list)

let run ?(fmt=Format.std_formatter) label list =
  assert false

(*__________________________________________________________________________*)

let () = run "Testing iteration speed of different constructs"
  [
    compare "Array" [
      trial "unfolded" (fun () -> ());
      trial "enum+fold" (fun () -> ());
    ];
    compare "List" [
      trial "unfolded" (fun () -> ());
      trial "enum+fold" (fun () -> ());
    ];
  ]
