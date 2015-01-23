(** Stream based text formatting and printing *)

(** {6 Types} *)

type attr = Ansi.Style.t
type size = int
type line
type justification = [`left | `center | `right | `block | `none]

(** Raw input *)
type raw =
  | RFrag of string
  | RAttr of attr
  | RBreak
(* | RWordBreak *)
  | RLineBreak

(** Cooked output *)
type cooked =
  | CFrag of string
  | CAttr of attr
  | CSpace of int
  | CSeq of cooked array

(** {6 Lines} *)

val empty_line : line
val make_line : cooked array -> line
val line_width : line -> size
val line_concat : line list -> line

val width_of_first_line : line LazyList.t -> size
val max_width_over_all_lines : line LazyList.t -> size

(** {6 Layout} *)

val format :
  ?attr:attr ->
  ?fill:attr ->
  ?width:size ->
  ?just:justification ->
  raw LazyList.t -> line LazyList.t

val tabulate :
  ?attr:attr ->
  ?fill:attr ->
  line LazyList.t list -> line LazyList.t

val pad :
  ?fill:attr ->
  ?left:size ->
  ?right:size ->
  ?top:size ->
  ?bottom:size ->
  line LazyList.t -> line LazyList.t

val indent :
  ?fill:attr ->
  size ->
  line LazyList.t -> line LazyList.t

(** {6 Printing} *)

type printer

val make_printer : ?ansi:bool -> out_channel -> printer

val print_lines : printer -> line LazyList.t -> unit
val print_newline : printer -> unit -> unit
val print_string : printer -> string -> unit
val print_ansi : printer -> attr -> unit
val printf : printer -> ('a, unit, string, unit) format4 -> 'a
val flush : printer -> unit

(**/**)

val justification_to_string : justification -> string

val dump_raw : out_channel -> raw LazyList.t -> unit
val dump : out_channel -> line LazyList.t -> unit

