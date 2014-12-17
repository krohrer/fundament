type 'a t = 
    { mutable count : int;
      mutable block : Obj.t }

type index = int

let make ?(cap=8) () =
  assert (0 <= cap);
  { count = 0;
    block = Obj.new_block 0 cap }

let init count f =
  let block = Obj.new_block 0 count in
  for i = 0 to count-1 do
    Obj.set_field block i (Obj.repr (f i))
  done;
  { count;
    block }

(* let from_callback ?cap cb = *)
(*   let v = make ?cap () in *)
(*   let idx = ref 0 in *)
(*   let rec cont x = *)
(*     let i = !idx + 1 in *)
(*     idx := i; *)
(*     cb cont i  *)
(*   in *)
(*   cb cont 0 *)

let count v = v.count
let capacity v = Obj.size v.block

let accomodate requested v =
  let old_cap = capacity v in
  if old_cap <= requested then begin
    let new_cap = max requested (old_cap * 2) in
    let old_block = v.block in
    let new_block = Obj.new_block 0 new_cap in
    for i = 0 to count v - 1 do
      Obj.set_field new_block i (Obj.field old_block i)
    done;
    v.block <- new_block
  end

let set (v:'a t) i (o:'a) = 
  assert (0 <= i && i <= count v);
  Obj.set_field v.block i (Obj.repr o)

let insert v o =
  let index = count v in
  accomodate index v;
  v.count <- index + 1;
  set v index o;
  index

let get (v:'a t) i : 'a =
  assert (0 <= i && i <= count v);
  Obj.obj (Obj.field v.block i)

let swap v i j =
  let t = get v i in
  set v i (get v j);
  set v j t

let shuffle ~rand v =
  assert false

let copy ?compact v =
  assert false

let compact v =
  assert false

(*__________________________________________________________________________*)

let preinc r = let i = !r in r := i + 1; i

let enum vec =
  let cur = ref 0 in
  let rec cont b ~it =
    let i = preinc cur in
    if i < count vec then
      it (get vec i) b ~cont
    else
      b
  in
  fun b cee -> cee b ~cont

(*__________________________________________________________________________*)

type 'a printer = Format.formatter -> 'a -> unit

let print pr fmt v = Format.(
  pp_open_box fmt 2;
  pp_print_string fmt "[!";
  pp_print_cut fmt ();
  let n = count v - 1 in
  if 0 < n then
    pr fmt (get v 0);
  for i = 1 to count v - 1 do
    pp_print_string fmt ";";
    pp_print_space fmt ();
    pr fmt (get v i)
  done;
  pp_print_cut fmt ();
  pp_print_string fmt "!]";
  ()
)
