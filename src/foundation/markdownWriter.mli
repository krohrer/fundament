(* Use phantom types? *)
type t = private PrettyPrinter.t

val underline : string -> char -> t

val title	: string	-> t
val text	: string	-> t
val header	: string	-> t
val paragraph	: string	-> t
val list	: t list	-> t
val ulist	: t list	-> t
val quoted	: ('a -> PrettyPrinter.t) -> 'a -> t

