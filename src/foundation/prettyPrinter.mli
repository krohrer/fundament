type t

(*   NOTE: See, compare, and update TODO.md.


     Pretty printers as a monoid structure, or whatever you wanna call it.

    f +++ pp0 === pp0 +++ f
    (f +++ g) +++ h === f +++ (g +++ h)

   I think we could maybe use composable iteratees here as well?
   To keep memory usage down?

   Upgrade Aesq to iteratees as well and use that for output instead?

   Use functorized printers / typed-tagless interpreter ?

*)
val (+++) : t -> t -> t
val pp0 : t

val pp_text		: string -> t
val pp_newline		: unit -> t

val pp_string		: string -> t
val pp_int		: int -> t
val pp_to_string	: ('a -> string) -> 'a -> t
val pp_format		: ('a, unit, string, t) format4 -> 'a

val pp_spc	: t
val pp_nbsp	: t
val pp_cut	: t
val pp_brk	: spc:int -> ind:int -> t
val pp_comma	: t

val pp_list	: elem:('a -> t) -> ?sep:t -> 'a list -> t
val pp_seq	: t list -> t

val pp_bracket		: string -> string -> t -> t
val pp_parenthesize	: t -> t
val pp_bracket_curly	: t -> t
val pp_bracket_square	: t -> t

type hint = [`H|`V|`HV|`HoV|`None]

val pp_boxed	: ?hint:hint -> ind:int -> t -> t
val pp_box	: ind:int -> t -> t
val pp_vbox	: ind:int -> t -> t
val pp_hbox	: t -> t
val pp_hvbox	: ind:int -> t -> t
val pp_hovbox	: ind:int -> t -> t

val pp_sexpr	: t -> t list -> t
val pp_sexprl	: string -> t list -> t
val pp_args	: t list -> t

val run_pp : ?formatter:Format.formatter -> t -> unit
