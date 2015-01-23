type color     = [ `black | `red | `green | `yellow | `blue | `magenta | `cyan | `white | `default ]
let all_colors = [|`black ; `red ; `green ; `yellow ; `blue ; `magenta ; `cyan ; `white ; `default|]

type intensity      = [ `faint | `normal | `bold ]
let all_intensities = [|`faint ; `normal ; `bold|] 

type decoration     = [ `underline | `none ]
let all_decorations = [|`underline ; `none|]

type style = {
  intensity	: intensity;
  decoration	: decoration;
  inverted	: bool;
  blink		: bool;
  foreground	: color;
  background	: color;
}

type sequence = string
type code = int

(*-----------------------------------*)

let intensity_to_string =
  function
    | `faint		-> "faint"
    | `normal		-> "normal"
    | `bold		-> "bold"

let decoration_to_string =
  function
    | `underline	-> "underline"
    | `none		-> "none"

let color_to_string =
  function
    | `black		-> "black"
    | `red		-> "red"
    | `green		-> "green"
    | `yellow		-> "yellow"
    | `blue		-> "blue"
    | `magenta		-> "magenta"
    | `cyan		-> "cyan"
    | `white		-> "white"
    | `default		-> "default"

(*-----------------------------------*)

module Code =
  struct
    type t = code

    let of_intensity =
      function
      | `bold		-> 1
      | `normal		-> 22
      | `faint		-> 2

    let of_decoration =
      function
      | `underline	-> 4 
      | `none		-> 24

    let of_inverted =
      function
      | true		-> 7
      | false		-> 27

    let of_blink =
      function
      | true		-> 5
      | false		-> 25

    let of_color base c =
      let code = match c with
	| `black	-> 0
	| `red	-> 1
	| `green	-> 2 
	| `yellow	-> 3
	| `blue	-> 4
	| `magenta	-> 5
	| `cyan	-> 6
	| `white	-> 7
	| `default	-> 9
      in
      code + base

    let of_foreground c =
      of_color 30 c

    let of_background c =
      of_color 40 c

  end

(*-----------------------------------*)

module Sequence =
  struct
    type t = sequence

    let of_codes codes =
      let buf = Buffer.create 20 in
      (
	match codes with
	| [] ->
	  ()
	| [c] ->
	  Printf.bprintf buf "\x1b[%dm" c
	| c::rest ->
	  Printf.bprintf buf "\x1b[%d" c;
	  List.iter (fun c -> Printf.bprintf buf ";%d" c) rest;
	  Buffer.add_string buf "m"
      );
      Buffer.contents buf

    let reset = "\x1b[0m"
  end

(*-----------------------------------*)

module Style =
  struct
    type t = style

    let default = {
      intensity		= `normal;
      decoration	= `none;
      inverted		= false;
      blink		= false;
      foreground	= `default;
      background	= `default;
    }

    let make
	?(inherits	= default)
	?(intensity	= inherits.intensity)
	?(decoration	= inherits.decoration)
	?(inverted	= inherits.inverted)
	?(blink		= inherits.blink)
	?(foreground	= inherits.foreground)
	?(background	= inherits.background)
	() =
      {
	intensity;
	decoration;
	inverted;
	blink;
	foreground;
	background;
      }

    let default = make ()

    let intensity a  = a.intensity
    let decoration a = a.decoration
    let inverted a   = a.inverted
    let blink a      = a.blink
    let foreground a = a.foreground
    let background a = a.background

    let set_intensity i a  = { a with intensity = i }
    let set_decoration u a = { a with decoration = u }
    let set_inverted i a   = { a with inverted = i }
    let set_blink b a      = { a with blink = b }
    let set_foreground c a = { a with foreground = c }
    let set_background c a = { a with background = c }

    let to_codes a =
      [ Code.of_intensity	a.intensity;
	Code.of_decoration	a.decoration;
	Code.of_inverted	a.inverted;
	Code.of_blink		a.blink;
	Code.of_foreground	a.foreground;
	Code.of_background	a.background ]

    let transition_to_codes a b =
      let codes = ref [] in
      let app_if_necessary c a b =
	if a <> b then
	  codes := c b :: !codes
	else
	  ()
      in
      app_if_necessary Code.of_intensity	a.intensity	b.intensity;
      app_if_necessary Code.of_decoration	a.decoration	b.decoration;
      app_if_necessary Code.of_inverted		a.inverted	b.inverted;
      app_if_necessary Code.of_blink		a.blink		b.blink;
      app_if_necessary Code.of_foreground	a.foreground	b.foreground;
      app_if_necessary Code.of_background	a.background	b.background;
      !codes

    let to_sequence a =
      Sequence.of_codes (to_codes a)

    let transition_to_sequence a b =
      Sequence.of_codes (transition_to_codes a b)

    let print ff c =
      Format.fprintf ff "@[I=%s,@ U=%s,@ N=%b,@ B=%b,@ Fg=%s,@ Bg=%s@]"
	(intensity_to_string c.intensity)
	(decoration_to_string c.decoration)
	c.inverted
	c.blink
	(color_to_string c.foreground)
	(color_to_string c.background)
  end
