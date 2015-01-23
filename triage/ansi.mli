(** ANSI attributes / escape sequences *)

(** {6 Types} *)

(** ANSI Escape sequence *)
type sequence = string
(** ANSI Escape code *)
type code = int
(** ANSI Text style *)
type style

(** ANSI colors *)
type color =
  [ `black
  | `red
  | `green
  | `yellow
  | `blue
  | `magenta
  | `cyan
  | `white
  | `default
  ]
(** ANSI intensity *)
type intensity =
  [ `faint
  | `normal
  | `bold
  ]
(** ANSI decoration *)
type decoration =
  [ `underline
  | `none
  ]


(** {6 Caps} *)

val all_colors      : color array
val all_intensities : intensity array
val all_decorations : decoration array


(** {6 Escape codes} *)
module Code :
  sig
    type t = code

    val of_intensity	: intensity -> t
    val of_decoration	: decoration -> t
    val of_inverted	: bool -> t
    val of_blink	: bool -> t
    val of_foreground	: color -> t
    val of_background	: color -> t
  end

(** {6 Escape sequences} *)
module Sequence :
  sig
    type t = sequence

    val of_codes : code list -> t
    val reset : t
  end

(** {6 Text style} *)
module Style :
  sig
    type t = style

    val default : t
  
    val make :
      ?inherits:t ->
      ?intensity:intensity ->
      ?decoration:decoration ->
      ?inverted:bool ->
      ?blink:bool ->
      ?foreground:color ->
      ?background:color ->
      unit -> t

    val intensity   : t -> intensity
    val decoration  : t -> decoration
    val inverted    : t -> bool
    val blink       : t -> bool
    val foreground  : t -> color
    val background  : t -> color

    val set_intensity   : intensity	-> t -> t
    val set_decoration  : decoration	-> t -> t
    val set_inverted    : bool		-> t -> t
    val set_blink       : bool		-> t -> t
    val set_foreground  : color		-> t -> t
    val set_background  : color		-> t -> t

    val to_sequence : t -> sequence
    val transition_to_sequence : t -> t -> sequence

    val print : Format.formatter -> t -> unit
  end


(** {6 Auxiliary} *)

(** Description of color *)
val color_to_string      : color -> string
(** Description of intensity *)
val intensity_to_string  : intensity -> string
(** Description of decoration *)
val decoration_to_string : decoration -> string

