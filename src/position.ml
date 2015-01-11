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

let indent = 2

let rec pp_print : type a. Format.formatter -> a t -> unit =
		       fun fmt -> function
  | None -> ()
  | Labeled (lbl,pos) ->
    Format.(pp_open_box fmt (String.length lbl + 2);
	    pp_print_string fmt lbl;
	    pp_print_string fmt ":";
	    pp_print_space fmt ();
	    pp_print fmt pos;
	    pp_close_box fmt ();
	    ())
  | Description (pos,text) ->
    Format.(pp_open_vbox fmt indent;
	    pp_print fmt pos;
	    pp_print_cut fmt ();
	    pp_print_text fmt text;
	    pp_close_box fmt ();
	    ())
  | Index i ->
    Format.(pp_print_int fmt i;
	    ())
  | OneOfTotal (i,n) ->
    Format.(pp_print_int fmt i;
	    pp_print_string fmt "/";
	    pp_print_int fmt n;
	    ())
  | Stream { name; pos; count } ->
    ()
  | ByteStream { name; pos; count } ->
    ()
  | TextStream { name; row; col } ->
    ()

				 
