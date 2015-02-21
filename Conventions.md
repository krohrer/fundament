Conventions
========================================================================

An overview of the guidelines that should ideally be followed for the
Fundament library. Rules are open to discussion with Kaspar Rohrer.

# Naming

* Types of names:
	- Mnemonic: 1-3 letters
	- Brief : 2~5 letters
	- Long : 5~10 letters
	- Full : descriptive name with however many letters it takes

* Use mnemonic names for type variables, e.g. ('a->'b) -> 'b->'a,
  except for type declarations in interface files, where longer names
  are permitted as long as they aid documentation and do not
  unneccessarily clutter the code (the ideal case are GADTs and
  phantom types, where the names only appear once.)
  
* Frequency of use ~ 1 / (Length of labels for functions)

* We make up for shorter names with better documentation.  So write
  descriptive names first, and abbreviate them as we write the
  documentation explaining the abbreviations.
  
* Do not use begin/end, except for heavily imperative code,
  e.g. external libraries. Use parentheses instead.
  
* Use the OCamlDoc format for now.

*  Type modules
   * Have a type t
   * And associated operations, e.g. pretty printing

## Development Process

- Development for new features should go like this:
  1. scratch.ml file first
  2. separate source file with "_Prototype.ml" suffix and makefile
     target (use the same name for the makefile as for the git branch).
  3. unit of files with tests and profiling
  4. separate library
  
