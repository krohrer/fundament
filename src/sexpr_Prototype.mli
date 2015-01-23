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

val to_aesq : t -> (aesq_t, out_channel) IterateeK.enumerator

val aesq_writer : out_channel -> (aesq_t, out_channel) IterateeK.t

(* val test : unit *)
