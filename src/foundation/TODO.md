- Write Dynamometer library with current interface
- More Enumee stuff!
  * For files?
  * For pretty printing?
- Enumee -> Continuee? Hell naw!

Q: What are enumees?

A: The iteratee concept adapted to the impure world of OCaml, using
continuations and recursive types to avoid unnecessary allocations.
See profiling.

Q: Can we model pretty printing using enumee? How?

A: A pretty printer is simply an enumee. I.e.
