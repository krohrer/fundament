# Frequently asked questions.

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
    reasonably fast with a few adaptions for generic
    maps/filters/folds/iterations over collections, and can be used
    instead of lists for the writers and pretty printers.
	
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


