default: prof-it

sexpr-proto:
	ocamlbuild sexpr_Prototype.native
	./sexpr_Prototype.native

dynamometer:
	ocamlbuild dynamometer.native
	./dynamometer.native

prof-it:
	ocamlbuild -cflags -rectypes profileIteratee.native
	@echo "Make: Compilation done. Starting profile..."
	./profileIteratee.native

stream-proto:
	ocamlbuild stream.native
	./stream.native

it-proto:
	ocamlbuild iterateeIK.native
	./iterateeIK.native

pp-proto:
	ocamlbuild prettyPrinting_Prototype.native
	./prettyPrinting_Prototype.native

test-it:
	ocamlbuild test_iterateeK.native
	./test_iterateeK.native

dump:
	@echo "Make: Dumping CMM"
	ocamlbuild -cflags -rectypes profileIteratee.cmx
	ocamlopt -rectypes -I _build -dcmm profileIteratee.ml #2> profileIteratee.cmm

scratch:
	ocamlbuild -cflags -rectypes scratch.native
	./scratch.native

test:
	ocamlbuild testVector.byte
	./testVector.byte

scratch.cmm:
	ocamlbuild scratch.cmx
	ocamlopt -I _build -dcmm scratch.ml 2> scratch.cmm

# vector.cmm:
# 	ocamlbuild vector.cmx
# 	ocamlopt -I _build -dcmm vector.ml 2> vector.cmm

vector.native: vector.mli vector.ml
	ocamlbuild vector.native

profile:
	ocamlbuild profileLazyList.native && ./profileLazyList.native

sanitize:
	_build/sanitize.sh
