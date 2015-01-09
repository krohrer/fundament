(** A generic position description which is by nature either a brief
    indicator or a more complete prosaic form, with a human readable
    description. *)

type brief and prosaic

and _ t =
  | None	: _ t
  | Labeled	: label * brief t			-> brief t
  | Description	: brief t * string			-> prosaic t
  | Index	: int					-> brief t
  | OneOfTotal	: int * int				-> brief t
  | Stream	: { name:string; pos:int; count:int }	-> brief t
  | ByteStream	: { name:string; pos:int; count:int }	-> brief t
  | TextStream	: { name:string; row:int; col:int }	-> brief t

and label	= string
and text	= string

val pp_print : Format.formatter -> 'a t -> unit
