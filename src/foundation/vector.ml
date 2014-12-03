module Null =
  struct
    let null = Obj.repr 0
  end

type 'a t = 
    { mutable count : int;
      mutable array : Obj.t array }

type index = int

let make ?(cap=8) () =
  assert (0 <= cap);
  { count = 0;
    array = Array.make cap Null.null }

let init count f =
  (* Very unsafe due to special float handling:

     let array = Obj.magic (Array.init count f) in
     ...

     But is it safe this way?
  *)
  let array = Array.init count (fun i -> Obj.repr (f i)) in
  { count; array }

let from_callback ?cap cb =
  let v = make ?cap () in
  assert false

let count v = v.count
let capacity v = Array.length v.array

let accomodate requested v =
  let old_cap = capacity v in
  if old_cap <= requested then begin
    let new_cap = max requested (old_cap * 2) in
    let old_array = v.array in
    let new_array = Array.make new_cap Null.null in
    for i = 0 to count v - 1 do
      new_array.(i) <- old_array.(i)
    done;
    v.array <- new_array
  end

let set (v:'a t) i (o:'a) = 
  assert (0 <= i && i <= count v);
  v.array.(i) <- Obj.repr o

let set_count v n =
  assert (n <= capacity v);
  v.count <- n

let insert v o =
  let new_index = count v in
  accomodate new_index v;
  set_count v new_index;
  set v new_index o;
  new_index

let get (v:'a t) i : 'a =
  assert (0 <= i && i <= count v);
  Obj.obj v.array.(i)

let swap v i j =
  let t = get v i in
  set v i (get v j);
  set v j t
