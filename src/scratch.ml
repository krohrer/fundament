module type M = sig
  type s
  val x : s ref
  val y : int
end

type 's m = (module M with type s = 's)

type t =
  | Mod : { x : 's m } -> t

module M =
  struct
    type s = bool
    let x = ref true
    let y = 0
  end

(* let _ = Mod { x = (module M) } *)


(*
module type S =
  sig
    val str : string -> unit
    val nl : unit -> unit
  end

module StdOut : S =
  struct
    let str = print_string 
    let nl = print_newline
  end

let test p =
  let module P = (val p : S) in P.(
    str "Hello world"; nl ();
    str "Just testing"; nl ()
  )

let _ = run (module StdOut

module type GF = functor () -> sig end

let execute m = 
  let module M = (val m : GF) () in ()


module Run (P : S) () =
  struct
    open P
      
    let () =
      str "Hello world"; nl ();
      str "Just testing"; nl ()
  end

type (_,_,_) t =
  | Init : (_ -> 't) -> ((_,_,_) t as 't)
*)
