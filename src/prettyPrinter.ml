type t = Format.formatter -> unit

let pp0 ff = ()
let (+++) f g = fun ff -> f ff; g ff
let ( *** ) f x = f x

(* f +++ pp0 === pp0 +++ f *)
(* (f +++ g) +++ h === f +++ (g +++ h) *)

let pp_text txt ff = Format.pp_print_text ff txt
let pp_string s ff = Format.pp_print_string ff s
let pp_int i ff = Format.pp_print_int ff i
let pp_spc ff = Format.pp_print_space ff ()

let pp_format fmt =
  Format.ksprintf (fun s ff -> Format.pp_print_string ff s) fmt

let pp_to_string f x ff = Format.pp_print_string ff (f x)
let pp_nbsp ff = Format.pp_print_string ff " "

let pp_comma = pp_string "," +++ pp_spc

let pp_list ~elem ?(sep=pp0) list ff =
  let rec fold = function
    | []	-> ()
    | [x]	-> elem x ff
    | x::rest	-> elem x ff; sep ff; fold rest
  in
  fold list

let pp_seq = List.fold_left (+++) pp0

let pp_bracket sopen sclose pp = pp_string sopen +++ pp +++ pp_string sclose
let pp_parenthesize pp = pp_bracket "(" ")" pp
let pp_bracket_curly pp = pp_bracket "{" "}" pp
let pp_bracket_square pp = pp_bracket "[" "]" pp

type hint = [`H|`V|`HV|`HoV|`None]

let pp_hbox pp ff =
  Format.pp_open_hbox ff ();
  pp ff;
  Format.pp_close_box ff ()

let pp_vbox ~ind pp ff =
  Format.pp_open_vbox ff ind;
  pp ff;
  Format.pp_close_box ff ()

let pp_hvbox ~ind pp ff =
  Format.pp_open_hvbox ff ind;
  pp ff;
  Format.pp_close_box ff ()

let pp_hovbox ~ind pp ff =
  Format.pp_open_hovbox ff ind;
  pp ff;
  Format.pp_close_box ff ()

let pp_box ~ind pp ff =
  Format.pp_open_box ff ind;
  pp ff;
  Format.pp_close_box ff ()

let pp_boxed ?(hint=`None) ~ind pp ff =
  match hint with
  | `H		-> pp_hbox pp ff
  | `V		-> pp_vbox ~ind pp ff
  | `HV		-> pp_hvbox ~ind pp ff
  | `HoV	-> pp_hovbox ~ind pp ff
  | `None	-> pp_box ~ind pp ff
  
let pp_cut ff = Format.pp_print_cut ff ()
let pp_brk ~spc ~ind ff = Format.pp_print_break ff spc ind

let pp_args l =
  pp_list ~elem:(fun x->x) ~sep:pp_spc l

let pp_sexpr label args =
  let body = pp_list ~elem:(fun x -> x) ~sep:pp_spc args in
  pp_hvbox ~ind:2 (
    pp_parenthesize (
      label +++ pp_spc +++ pp_hovbox ~ind:0 body))

let pp_sexprl name args =
  pp_sexpr (pp_string name) args

let run_pp ?(formatter=Format.std_formatter) pp = pp formatter
