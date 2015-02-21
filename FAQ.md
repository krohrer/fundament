# Frequently asked questions.

**Why the name "fundament"?**

Originally, I used "foundation" as a name, but the objective-c base
library for Apple's "OS X" and "iOS" already has the same name.
	
And because "fundament" is a word in German and English. It also
sounds super cool.
	
**What is the deal with those iteratees?**
	
Originally, I had the idea of higher order functions for collections
of objects that either consume or produce a stream of elements.
	
After playing around for a bit, I decided to revisit Oleg's paper on
Iteratees, which certainly inspired me in the first place.
	
They provide a nice abstraction over sequences of objects with
built-in resource management and error handling/reporting, can be
reasonably fast with a few adaptions for generic
maps/filters/folds/iterations over collections, and can be used
instead of lists for the writers and pretty printers.
	
**Maybe I should package individual components in the fundament
library separately?**
	
Since this is still in the prototyping stage and I am the sole user, I
simply do not see the need (yet).

**What are enumees / iteratees?**

The iteratee concept adapted to the impure world of OCaml, using
continuations and recursive types to avoid unnecessary allocations.
See profiling. After some microprofiling of different approaches, I am
now almost certain that the approach in the current IterateeK module
is the best one.
	
Enumees were the first prototypes that only used recursive function
types and thus were less powerfull than the current IterateeK variant.



