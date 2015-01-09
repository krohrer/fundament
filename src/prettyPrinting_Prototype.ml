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
    type t = Format.formatter -> unit
  end

module type AesqFormat_Sig =
  sig
    type t
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

(* Markdown writer, an example of an iteratee based pretty printer *)
(*__________________________________________________________________________*)

module type MarkdownWriter_Sig =
  sig
    type t 


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
    module FromStandardFormat(F : StandardFormat.S) = struct type t = F.t end
    module FromAesqFormat(F : AesqFormat.S) = struct type t = F.t end
  end

(* Article writer *)
(*__________________________________________________________________________*)

type contributor = string

module type ArticleWriter_Sig =
  sig
    type t
    type 'a elem

    val str : string -> [`text] elem
    val int : int -> [`text] elem
    val p : [`text] elem list -> [`paragraph] elem

    val article :
      title:[`text] elem ->
      authors:contributor list ->
      abstract:[`text] elem list ->
      [`paragraph] elem list -> t
  end

module ArticleWriter :
  sig
    module type S = ArticleWriter_Sig

    module WithMarkdown (W : MarkdownWriter.S) : S with type t = W.t
  end
  =
  struct
    module type S = ArticleWriter_Sig

    module WithMarkdown (W : MarkdownWriter.S) =
      struct
	type t = W.t
	type 'a elem =
	  | Str : string -> [`text] elem
	  | Int : int -> [`text] elem
	  | P : [`text] elem list -> [`paragraph] elem
      end
  end

(* Article writer

   What we want here ideally, would be an embedded DSL in the form of
   composable values. 
   
*)

let iteratee_article writer =
  let module W = (val writer : ArticleWriter.S) in W.(
    article
      ~title:"Hello world"
      ~author:"Kaspar M. Rohrer"
      ~abstract:[
	
      ]
      [
	
      ]
  )
  
