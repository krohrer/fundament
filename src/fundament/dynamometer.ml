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
    
type run_flag =
  | Keep_value_alive_during_gc

module Flags = Set.Make(struct 
  type t = run_flag
  let compare = compare
end)

type 'a t =
  | Trial	: label * 'b thunk	-> trial t
  | Compare	: label * compare	-> group t
  | Group	: label * group t list	-> group t

and trial
and group

and label = string

and 'a thunk = unit -> 'a

and measurement =
  | MeasureMemory	of (Gc.stat -> Gc.stat -> float) * float array
  | MeasureTime		of float array

and compare =
    { random		: Random.State.t;
      flags		: Flags.t;
      repeat		: int;
      probes		: probe array;
      trials		: trial t array; 
      ranking		: int array;
      stats		: Stats.t option array;
      measurements	: trial:int -> probe:int -> float array }


and probe = Probe.t

(*__________________________________________________________________________*)

let trial label thunk = Trial (label, thunk)

let compare label ?(flags=Flags.empty) ?random ?(repeat=1) ?(probes=Probe.defaults) trials =
  let random =
    match random with
    | None	-> Random.State.make_self_init ()
    | Some r	-> r
  in
  let probes		= Array.of_list probes in
  let trials		= Array.of_list trials in
  let probe_count	= Array.length probes in
  let trial_count	= Array.length trials in 
  let ranking		= Array.make repeat (-1) in
  let stats		= Array.make repeat None in
  let measurements =
    let table = Array.init (probe_count * trial_count) (fun _ -> Array.make repeat nan) in
    fun ~trial ~probe -> table.(trial * probe_count + probe)
  in
  Compare (label, { random;
		    flags;
		    repeat;
		    probes;
		    trials;
		    ranking;
		    stats;
		    measurements })

let group =
  fun label list -> Group (label, list)

(*__________________________________________________________________________*)

let rec run_group fmt label list = 
  let results = assert false in
  print_group fmt label results

and print_group fmt label results = Format.(
  pp_print_string fmt label;
  pp_print_newline fmt ();
  pp_print_newline fmt ();
  pp_print_string fmt (String.map (fun _ -> '-') label);
  pp_print_newline fmt ();
  pp_open_block
  
  ())
  
and run_trial fmt label thunk comp =
  assert false

and run_compare fmt label comp =
  assert false

and print_header fmt title description = Format.(
  pp_print_newline fmt ();
  pp_print_string fmt title;
  pp_print_newline fmt ();
  pp_print_string fmt (String.map (fun _ -> '=') title);
  pp_print_newline fmt ();
  pp_print_newline fmt ();
  pp_print_text fmt description;
  pp_print_newline fmt ();
  pp_print_newline fmt ();
  ())

let run ?(fmt=Format.std_formatter) ~title ~description list =
  print_header fmt title description;
  list |> List.iter
      (function
      | Group (label, list)	-> run_group fmt label list
      | Compare (label, cmp)	-> run_compare fmt label cmp)

(*__________________________________________________________________________*)

let () = run "Testing iteration speed of different constructs"
  "This is simply an example description for an example use case"
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
