Things to Do
========================================================================

A collection of snippets and ideas concerning the improvement and
evolution of the Fundament library.


## Pinboard

A very rough list of open issues:

- [ ] Write Dynamometer library with current interface
  - [ ] finish DSL implementation, see Dynamometer module.
  - [ ] Write examples
	- [ ] Which is faster:
	
			let f x y = match y with ...
		
			let f x = function ...

- [ ] Finalize interatee interface and operators (See IterateeK)
  - [X] Avoid closures as it allocates on the heap.
	  - [X] For the cost of purity (use a more imperative
        implementation)
	- [X] Use continuation passing style.
  - [ ] Semantics of concatenation/composition?
	  - [X] Monadic operations
	  - [X] Higher-order operations (map,fold,filter,iter)
	  - [X] Function composition for catenation of enumerators.
  - [ ] Use first class modules for better error reporting
  - [ ] Write a variant of iterateeK that takes positions/indices as well
	  - See IterateeIK
	  - [ ] Harmonize Iteratee* variants.

- [ ] Write unit tests and examples for IterateeK.

- [ ] Write pretty printer iteratees/enumeratees
  - [ ] for ANSI-Escaped text
  - [ ] for Markdown
  - [ ] for Sexpr
  - [ ] for ...

- [ ] Decide what to include in this library:
  * The basic stuff
  * sequences / transformations
	- generation / iteration
	- production / consumption.
	- iteratees / enumerators / enumeratee / ...
  * Various DSL for doing pretty printing based on the above
	- Printing interfaces vs. implementations
  * Colored, justified, possibly hyphenated, tabulated, quoted,
    preformatted, ANSI escape code based - text output using Aesq
    iteratee.
  * Not sure about the parsing yet.

  
## Open Questions / Status Reports

** What is the status of enumerators and enumeratees? **

More and more I feel that the enumerator and enumeratee don't hold up
in an unpure world.

Instead, each module that provides an iteratee implementation should
provide custom, efficient combinators.

So let's write some examples and see where it goes. Worst thing that
could happen is that I finally understand those concepts better.

Here are a few ideas for examples:

- Salvage triage/{ansi,text}.{ml,mli} and write an iteratee based
  combinator library for ansi text output on stdout, channels,
  generic output.

- Write a generic iteratee-based s-expression pretty printer
  functor that takes the available combinators as a module argument.

See, now I think we are finally getting somewhere. Instead of being
overly general, we implement iteratee-based DSLs as
final-typed-tagless interpreters.

**Should we model pretty printers as enumerators or iteratees?**

Iteratees. And pretty printer programs as enumerators.

*What's the status for pretty printing?**

For pretty printing, a DSL approach for higher level Additionally
printing final-typed-tagless interpreters in the form of functors are
probably a good idea to provide

**What's the status for enumees/iteratees?**

_[21.12.2015]:_ IterateeK and IterateeIK are probably the way
forward.

_[26.12.2014]:_ The Iteratee module as it stands seems to offer a performant way
(based on some kind of continuation-passing style to reduce
heap-memory allocations)[1] to iterate/fold/... over sequences of
elements with automatic resource management.
	
I'm probably going with composable, unpure system (hm, kind of an
oxymoron). Maybe concatenable would be the better word?

[1]: Profiled with dynamometer precursor in ProfileEnumee.

		
## Idea freezer

Storage for bigger ideas.

### Blog

I should maybe blog about this?

Titles of articles (The blog as a program with source-code quotations from the OCaml compiler output):

- [ ] Fast, continuation-based, (composable?) constant-space iteratees
    in OCaml. Part (1)
	
- [ ] An excursion into microprofiling (Part 1)
	
- [ ] An excursion into microprofiling (Part 2, Dynamometer)
	
- [ ] We want fast, constant-space pretty printing!
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
		
Ideally, I would like an OCaml based blogging framework for static site generation.
* Disable dynamic site features for github upload.
* Enable dynamic site features when deploying to the cloud.
		
### The blog as an ever evolving, versioned program.

Running the program with different interpreters generates different
results.
	
- Articles as functor implementations (FTTI)
- Programs as generative functor applications?
- Pretty printers as functor parameter.
	
- Markdown articles with interspersed pieces of code, and optional
  code documentation. Would need a markup parser.  Formalized markdown
  replacement?  -> Name? Steno? Brief? Briefs? (haha,humour me)
	
Very crazy idea: extract source code from documentation / articles.
See Knuth's literate programming :)
	
Even crazier idea: GUI with live editing and recompilation -> Emacs.
	
Just add extraction of source code and git commit as another build
step.
	
Needs bootstraping to work for this library?


## Trashcan

Feel free to recover stuff in here from version control.

...Snip...

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

A2: Certainly not worth to invest too much time on my own here, unless
it is a preexisting solution, either ocamlp4 or using attributes.
