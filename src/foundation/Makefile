dynamometer:
	ocamlbuild dynamometer.native
	./dynamometer.native

profileIteratee:
	ocamlbuild -cflags -rectypes profileEnumee.native
	@echo "Make: Compilation done. Starting profile..."
	./profileEnumee.native

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
