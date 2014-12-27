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

## Pinboard

- Enumee -> Iteratee!
  - Semantics of composition / operators.
- Finalize interatee interface and operators (See Iteratee)
  - Avoid closures as it allocates on the heap.
  - Use continuation passing style.
  - Semantics of concatenation/composition?
- Write pretty printer iteratees/enumeratees
  * for ANSI-Escaped text
  * for Markdown
  * for Sexpr
  * for ...
- Write Dynamometer library with current interface
  * finish DSL
  * pretty printing as a functor!
  
  
## FAQ / Ideas

Q: Why the name "fundament"?

	A: Originally, I used "foundation" as a name, but the objective-c
    base library for Apple's "OS X" and "iOS" already has the same
    name.
	
	And because "fundament" is a word in German and English. It also
    sounds super cool.

Q: What's the status as of 26.12.2014? for enumees/iteratees

	A: The Iteratee module as it stands seems to offer a performant
    way (based on some kind of continuation-passing style to reduce
    heap-memory allocations)[1] to iterate/fold/... over sequences of
    elements with automatic resource management.
	
	I'm probably going with composable, unpure system (hm,
    kind of an oxymoron). Maybe concatenable would be the better word?

[1]: Profiled with dynamometer precursor in ProfileEnumee.

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


Q: What are enumees?

	A: The iteratee concept adapted to the impure world of OCaml,
	using continuations and recursive types to avoid unnecessary
	allocations.  See profiling. After some microprofiling of
	different approaches, i am now almost certain that the approach in
	the current Iteratee module is the best one. TODO: I just have to
	figure out the semantics of composition first
	
	TODO: Probably deprecating the name enumees really soon!

Q: Should we model pretty printers as enumerators or iteratees?

	A: Iteratees. And pretty printer programs as enumerators.


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

