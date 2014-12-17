let () =
  let fmt = Format.std_formatter in
  let v = Vector.init 10 float in
  ignore (Vector.insert v nan);
  Vector.print Format.pp_print_float fmt v

