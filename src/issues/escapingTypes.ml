(* Hi List

   I was playing around with GADTs over the last few days and
   encountered the following problem (reduced to a minimal case here):
*)

type t =
  | App : {k:'t . 'a->'t->'t; s:'a} -> t

let munge : ('a->'t->'t as 'k) -> 'k = fun k -> fun s r -> k s r

let transform = function
  | App {k;s} -> App {k=munge k;s}

(* Note that I am using inlined records, which are only available in
   the unreleased 4.03 version. But I get the same error when using a
   separate record in OCaml 4.01, i.e.:

   type t = App : 'a app_t -> t
   and 'a app_t = { k : 't. 'a->'t->'t; s:'a }

   OCaml will choke on the transform function with the following
   error:

   Error: This field value has type a#17 -> 'b -> 'b which is less
   general than 't. 'a -> 't -> 't
*)

(* If I add type annotations like so: *)

let transform_annotated = function
  | App {k;s} -> App {k=(munge k : 'a->'t->'t);s=(s:'a)}

(* OCaml will instead give me an error about escaping types:

   Error: This expression has type a#19 -> 'a -> 'a
   but an expression was expected of type a#19 -> 't -> 't
   The type constructor a#19 would escape its scope

   I can work around this whole problem by inlining the munge
   function:
*)

let transform_inline = function
  | App {k;s} -> let k' s r = k s r in App {k=k';s}

(* This works but it is not ideal for my case, as it leads to somewhat
   unwieldy match expressions.

   Can somebody explain to me why the first case does not work?
   Especially when considering that the types should be equal
   (substituting the %identity function for munge produces the the
   same error).

   Thanks in advance

   Kaspar M. Rohrer
*)
