(*__________________________________________________________________________*)
(*

  Composable pretty printers using OCamls module system and functors (functions
  from module to module).

  Still not sure what the pretty printer type should be.
  
  Q: Also what would be a good name for our low level pretty printer?
  A: Why not simply use the existing Aesq printer?

  Q: What interface do we acctually want to support?
  A: Start with the language you would use to write articles.
*)


(* Basic formatting *)
(*__________________________________________________________________________*)

module type StandardFormat_Sig =
  sig
    val formatter : Format.formatter
  end

module type AesqFormat_Sig =
  sig
  end

module AesqFormat :
  sig
    module type S = AesqFormat_Sig
  end
  =
  struct
    module type S = AesqFormat_Sig
  end

module StandardFormat :
  sig
    module type S = StandardFormat_Sig
  end
  =
  struct
    module type S = StandardFormat_Sig
  end

(* Markdown writer *)
(*__________________________________________________________________________*)

module type MarkdownWriter_Sig =
  sig
  end

module MarkdownWriter :
  sig
    module type S = MarkdownWriter_Sig
    module FromStandardFormat(F : StandardFormat.S) : S
    module FromAesqFormat(F : AesqFormat.S) : S
  end
  =
  struct
    module type S = MarkdownWriter_Sig
    module FromStandardFormat(F : StandardFormat.S) = struct end
    module FromAesqFormat(F : AesqFormat.S) = struct end
  end

(* Article writer *)
(*__________________________________________________________________________*)

module ArticleWriter :
  sig
    module type S =
      sig
      end

    module FromMarkdown(W : MarkdownWriter.S) () : S
  end
  =
  struct
    module type S =
      sig
      end

    module FromMarkdown(W : MarkdownWriter_Sig) () =
      struct
      end
  end

(* Article writer

   What we want here ideally, would be an embedded DSL in the form of
   composable values. 
   
*)
(*__________________________________________________________________________*)

module Iteratees_1 (W : ArticleWriter.S) () :
  sig

  end
  =
  struct

  end

(* Graveyard, remnants of the past *)
(*__________________________________________________________________________*)

(* Writers need to be iteratee based! Composable iteratees a must!

   How can we work with the Iteratee module? *)

module Test :
  sig
    (* val dup : ('i,'o,'a) Iteratee.t -> ('i,'o,'a) Iteratee.t *)
  end
  =
  struct
  end

module F () =
  struct
    let _ = print_endline "F ()"
  end

