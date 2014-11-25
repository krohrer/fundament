type yes
type no

module Parser :
  sig
    type 'a t
  end

module Filesystem :
  sig
    type path
    type stats
    type file
    type ioerror

    module Path :
      sig
	type t = path

	val make_parser : unit -> t Parser.t
	val append : t -> t -> t
	val root : t

	val exists : t -> bool
	val stats : t -> stats option
      end

    module Stream :
      sig
	type +'a t

	exception Error of ioerror 

	val open_for_input		: Path.t -> <r:yes> t
	val open_for_output		: Path.t -> [`append|`overwrite] -> <w:yes> t
	val open_for_input_output	: Path.t -> <w:yes;r:yes> t
	val reopen			: 'a t -> 'a t

	val close			: 'a t -> unit

	val skip			: 'a t -> int -> unit
	val read			: <r:yes;..> t -> buf:bytes -> start:int -> len:int -> int
	val write			: <w:yes;..> t -> buf:bytes -> start:int -> len:int -> int
      end

    module Memory_mapped :
      sig
	(* Meh *)
      end
  end

module Resource_system :
  sig
    type 'a resource
  end

module Application :
  sig
    class t : object end
  end

module Window_manager :
  sig
    class t : object end
  end

module Configuration :
  sig
    type 'a t
  end

module Opengl_renderer :
  sig
  end

module Tile_renderer :
  sig
  end

module Text_renderer :
  sig
  end

module Input_manager :
  sig
  end

module LazyList : sig end
module Dot	: sig end
module Sexpr	: sig end
module Text	: sig end
module Aesq	: sig end
module Zimt	: sig end
module Math	: sig end
module Geom	: sig end
module Printer	: sig end

module Net		: sig end
module Interface	: sig end
module Console		: sig end
