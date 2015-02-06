module type Recur = 
  sig
    type p
    type e
    type s
    type r
    type t
     
    val copy : s -> s
    val extract : s -> r option
    val return : r -> t

    val k : s -> p -> e -> (r->'a) -> (p -> exn -> 'a) -> 'a -> 'a
  end

type ('p,'e,'s,'r,'t) recur = (module Recur with type p = 'p
					    and type e = 'e
					    and type s = 's
					    and type r = 'r
					    and type t = 't)


type ('p,'e,'r) t =
  | Done : 'r -> (_,_,'r) t
  | Cont : ('p->'e->('p,'e,'r) t) -> ('p,'e,'r) t
  | Recur : { s : 's; m : ('p,'e,'s,'r,('p,'e,'r2) t) recur } -> ('p,'e,'r2) t
