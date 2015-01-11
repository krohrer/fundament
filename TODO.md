# Fundament library with
	* The basic stuff
	* sequences / transformations
	  * generation / iteration
	  * production / consumption.
	  * iteratees / enumerators / enumeratee / ...
	* Various DSL for doing pretty printing based on the above
	  - Printing interfaces vs. implementations
	* Colored, justified, possibly hyphenated, tabulated, quoted,
      preformatted, ANSI escape code based - text output using Aesq
      iteratee.
	* Not sure about the parsing yet.
	
## Prerequisites

I use embedded records and (G)ADTs, so OCaml 4.03 will be needed (for
the records). Just do an opam switch to the latest (development)
version.
	
## Pinboard

- Write Dynamometer library with current interface
  * finish DSL
  * pretty printing as a functor!

- Finalize interatee interface and operators (See IterateeK)
  - [X] Avoid closures as it allocates on the heap.
	  - [X] At the cost of mutable style
  - [X] Use continuation passing style.
  - [X] Semantics of concatenation/composition?
	  - [X] Monadic operations
	  - [X] Higher-order operations (map,fold,filter,iter)
	  - [X] Function composition for catenation of enumerators.

- Write unit tests and examples for IterateeK.

- Write pretty printer iteratees/enumeratees
  * for ANSI-Escaped text
  * for Markdown
  * for Sexpr
  * for ...
  
## Development Process

- Development for new features should go like this:
  1. scratch.ml file first
  2. separate source file with "_Prototype.ml" suffix and makefile
     target (use the same name for the makefile as for the git branch).
  3. unit of files with tests and profiling
  4. separate library
  
## Coding conventions

TODO: Move to separate document.

* Types of names:
	- Mnemonic: 1-3 letters
	- Brief : 2~5 letters
	- Long : 5~10 letters
	- Full : descriptive name with however many letters it takes

* Use short names for type variables, e.g. ('a->'b) -> 'b->'a

*  Type modules
   * Have a type t
   * And associated operations, e.g. pretty printing

## FAQ / Ideas

Q: Why the name "fundament"?

	A: Originally, I used "foundation" as a name, but the objective-c
    base library for Apple's "OS X" and "iOS" already has the same
    name.
	
	And because "fundament" is a word in German and English. It also
    sounds super cool.
	
Q: What is the deal with those iteratees?
	
	A: Originally, I had the idea of higher order functions for
    collections of objects that either consume or produce a stream of
    elements.
	
	After playing around for a bit, I decided to revisit Oleg's paper
    on Iteratees, which certainly inspired me in the first place.
	
	They provide a nice abstraction over sequences of objects with
    built-in resource management and error handling/reporting, can be
    reasonably fast with a few adaptions, and can be used instead of
    lists for the writers and pretty printers.
	
Q: Maybe I should package individual components in the fundament
library separately?
	
	A: Since this is still in the prototyping stage and I am the sole
    user, I simply do not see the need (yet).

Q: What's the status as of 26.12.2014? for enumees/iteratees

	A: The Iteratee module as it stands seems to offer a performant
    way (based on some kind of continuation-passing style to reduce
    heap-memory allocations)[1] to iterate/fold/... over sequences of
    elements with automatic resource management.
	
	I'm probably going with composable, unpure system (hm,
    kind of an oxymoron). Maybe concatenable would be the better word?

[1]: Profiled with dynamometer precursor in ProfileEnumee.

Q: What are enumees / iteratees?

	A: The iteratee concept adapted to the impure world of OCaml,
	using continuations and recursive types to avoid unnecessary
	allocations.  See profiling. After some microprofiling of
	different approaches, i am now almost certain that the approach in
	the current IterateeK module is the best one.
	
	Enumees were the first prototypes that only used recursive
    function types and thus were less powerfull than the current
    IterateeK variant.

Q: Should we model pretty printers as enumerators or iteratees?

	A: Iteratees. And pretty printer programs as enumerators.

## Idea storage:

Q: Maybe I should blog about this?

A: Titles of articles (The blog as a program with source-code quotations from the OCaml compiler output):

	- Fast, continuation-based, (composable?) constant-space iteratees
    in OCaml. Part (1)
	
	- An excursion into microprofiling (Part 1)
	
	- An excursion into microprofiling (Part 2, Dynamometer)
	
	- We want fast, constant-space pretty printing!
	
	- Pretty printer example.
	- Array and List and Vector interface.
	- Parser?
	
	- Semantics?
	
	- Results? Comparison with other implementations?
	
	- Collapse sequences of enumerators / iteratees / enumeratees
	
		- E.g. concatenating files for line-based input (enumerators)
		- line-based pretty printer
		- text-based pretty printer
		- expression-based pretty printer
		- how can we model recursion using iteratees?
		
Q: The blog as an ever evolving, versioned program.

	Running the program with different interpreters generates
    different results.
	
	Articles as functor implementations.
	Programs as generative functor applications?
	Pretty printers as functor parameter.
	
	Markdown articles with interspersed pieces of code, and
    optional code documentation. Would need a markup parser.
	Formalized markdown replacement?
	-> Name? Steno? Brief? Briefs? (haha,humour me)
	
	Very crazy idea: extract source code from documentation / articles.
	See Knuth's literate programming :)
	
	Even crazier idea: GUI with live editing and recompilation.
	Emacs.
	
	Just add extraction of source code and git commit as another build
    step.
	
	Needs bootstraping to work?


## Graveyard of ideas:

Q: Maybe if certain functions could be tagged to be tailrecursive?
With attributes in the compiler?

	```
	(* Can be called anywhere *)
	let print _ = _

	(* Can only be called in tail position. *)
	let tail print _ = _

	(* Can only be called in tail position and may only call itself in
	tail position. *)
	let rec tail print _ = _
	```

A: Not sure it is worth the effort. Feeling that it can be modeled
using types instead.

