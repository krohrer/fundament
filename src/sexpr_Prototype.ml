(*__________________________________________________________________________*)

type t =
  | Atom : string -> t
  | List : (t, 'a) IterateeK.enumerator -> t

type aesq_t =
  | Fragment of string
  | Spaces of int
  | LineBreaks of int
  | Attr of aesq_attr

and aesq_attr =
  | Default
  | GreenOnBlack

let to_aesq : t -> (aesq_t, out_channel) IterateeK.enumerator = fun _ it ->
  IterateeK.step0 it (Fragment "TODO")

(*__________________________________________________________________________*)

module Aesq_writer =
  struct
    type state = out_channel

    let extract outc = Pervasives.flush outc; outc

    (* I should probably rewrite IterateeK.t.k, so that the
       continuation function takes the element last.

       Then, continuation functions can be written easily with pattern
       matching over the element, like so:

       let rec continuation outc _ recur = function ...
    *)

    let rec continuation outc aesq _ recur =
      match aesq with 
      | Fragment s	-> fragment_k outc recur s
      | Spaces n	-> spaces_k outc recur n
      | LineBreaks n	-> line_breaks_k outc recur n
      | Attr a		-> attr_k outc recur a

    and fragment_k outc recur s =
      output_string outc s;
      recur
      
    and spaces_k outc recur n =
      for i = 1 to n do output_string outc " " done;
      recur

    and line_breaks_k outc recur n =
      for i = 1 to n do output_string outc "\n" done;
      recur

    and attr_k outc recur = function
      | Default -> recur
      | GreenOnBlack -> recur

    let make outc = IterateeK.(
      recur
	~state:outc
	~extract
	{ continuation }
    )
  end

(*__________________________________________________________________________*)

let aesq_writer outc = Aesq_writer.make outc

let enum_test_data it =
  List.fold_left IterateeK.step0 it [
    Atom "hello-world"
  ]

(* let test = *)
(*   let consumer : (aesq_t,unit) IterateeK.t = aesq_writer stdout in *)
(*   let producer : (t,'a) IterateeK.enumerator = enum_test_data in *)
(*   let transformer : (t,aesq_t,'a) IterateeK.enumeratee = to_aesq in *)
(*   () *)
