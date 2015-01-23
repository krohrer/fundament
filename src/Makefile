default: test-it

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

it-proto:
	ocamlbuild iterateeK.native
	./iterateeK.native

pp-proto:
	ocamlbuild prettyPrinting_Prototype.native
	./prettyPrinting_Prototype.native

test-it:
	ocamlbuild test_iterateeK.native
	./test_iterateeK.native

dump:
	@echo "Make: Dumping CMM"
	ocamlopt -rectypes -I _build -dcmm enumee.ml 2> enumee.dcmm
	ocamlopt -rectypes -I _build -dcmm profileEnumee.ml 2> profileEnumee.dcmm

scratch:
	ocamlbuild -cflags -rectypes scratch.native
	./scratch.native

test:
	ocamlbuild testVector.byte
	./testVector.byte

# vector.cmm:
# 	ocamlbuild vector.cmx
# 	ocamlopt -I _build -dcmm vector.ml 2> vector.dcmm

vector.native: vector.mli vector.ml
	ocamlbuild vector.native

profile:
	ocamlbuild profileLazyList.native && ./profileLazyList.native

sanitize:
	_build/sanitize.sh
