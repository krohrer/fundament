dynamometer:
	ocamlbuild dynamometer.native
	./dynamometer.native

profileIteratee:
	ocamlbuild -cflags -rectypes profileEnumee.native
	@echo "Make: Compilation done. Starting profile..."
	./profileEnumee.native

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
