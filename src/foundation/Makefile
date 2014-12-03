vector.cmm:
	ocamlbuild vector.cmx
	cd _build
	ocamlopt -dcmm vector.ml vector.mli 

vector.native: vector.mli vector.ml
	ocamlbuild vector.native

profile.native:
	ocamlbuild profileLazyList.native && ./profileLazyList.native
