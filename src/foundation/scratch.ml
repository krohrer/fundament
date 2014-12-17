(* type ('a,'b) iteratee = *)
(*   | Done of 'b *)
(*   | Continue of ('a -> ('a,'b) iteratee) *)

(* type ('a,'b,'c) iteratee = *)
(*     cont:('a -> ('a,'b,'c) iteratee -> 'c) -> fin:('b -> 'c) -> 'c *)

(* type ('a,'b) t = cont:('a,'b) cont -> 'b -> 'b *)
(* and ('a,'b) cont = ('a -> ('a,'b) t) -> 'b -> 'b *)

type ('a,'b) t = cont:('a,'b) cont -> 'b
and ('a,'b) cont = 'b -> it:('a -> 'b -> ('a,'b) t) -> 'b

let preinc r = let i = !r in r := i + 1; i

module Test :
  sig
    val enum : 'a array -> ('a,'b) t -> 'b
    val fold : ('a -> 'b -> 'a) -> 'a -> ('b,'a) t
    val any_of : ('a -> bool) -> ('a,bool) t
    val all_of : ('a -> bool) -> ('a,bool) t
    val iter : ('a -> unit) -> ('a,unit) t
  end
  =
  struct
    let enum arr =
      let cur = ref 0 in
      let rec cont b ~it =
	let i = preinc cur in
	if i < Array.length arr then
	  it arr.(i) b ~cont
	else
	  b
      in
      fun cee -> cee ~cont

    let fold f =
      let rec it a b ~cont =
	cont (f b a) ~it
      in
      fun init ~cont ->
	cont init ~it

    let any_of pred =
      let rec it a b ~cont =
	pred a || cont b ~it
      in
      fun ~cont ->
	cont false ~it

    let all_of pred =
      let rec it a b ~cont =
	pred a && cont b ~it
      in
      fun ~cont ->
	cont true ~it

    let iter proc =
      let rec it a () ~cont =
	proc a; cont () ~it
      in
      fun ~cont ->
	cont () ~it
  end

let () =
  let a = Array.init 10 float in
  Test.enum a (Test.iter (Printf.printf "%f\n%!"))

let () =
  let a = Array.init 10 (fun x -> x) in
  Test.enum a (Test.fold (+) 0)

(* AWESOME! *)
