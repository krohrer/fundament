type (_,_,_) t = 
  | Done	: 'b					-> ( _, _,'b) t
  | Cont	: ('a->'t)				-> (('i,'a,'b) t as 't)
  | ICont	: ('i->'a->'t)				-> (('i,'a,'b) t as 't)
  | SCont	: 's * ('s -> 's) * ('s->'a->'t)	-> (('i,'a,'b) t as 't)
  | RCont	: 's * ('s -> 's) * ('s->'a->'t->'t)	-> (('i,'a,'b) t as 't)
  | XCont	: 's * ('s -> 's) * ('s->'a->'t->'t) * ('s->'b)	-> (('i,'a,'b) t as 't)
  | Error	: exn					-> ( _, _, _) t
  | Warning	: exn * 't				-> (( _, _, _) t as 't)

type ('i,'a,'b) enumerator = ('i,'a,'b) t -> ('i,'a,'b) t

(*__________________________________________________________________________*)

val enum_string		: string	-> (_,char,_) enumerator
val enum_list		: 'a list	-> (_,'a,_) enumerator
val enum_list'		: 'a list	-> (_,'a,_) enumerator
val enum_array		: 'a array	-> (_,'a,_) enumerator
val enum_array'		: 'a array	-> (_,'a,_) enumerator

val enumi_string	: string	-> (int,char,_) enumerator
val enumi_list		: 'a list	-> (int,'a,_) enumerator
val enumi_array		: 'a array	-> (int,'a,_) enumerator

val enum_from_foldl	: (('t->'b->'t)->'t->'c->'t) -> 'c -> 't -> ((_,'b,_) t as 't)

val enum_hashtbl : ('k,'v) Hashtbl.t -> ('k,'v,_) enumerator

val run : ('o -> 'r) -> (exn -> 'r) -> ('t -> 'r) -> ((_,_,'o) t as 't) -> 'r

(*__________________________________________________________________________*)

val copy : 't -> ((_,_,_) t as 't)

(*__________________________________________________________________________*)

val continue1 :
  ('a -> 't -> 't) ->
  'a -> 'x -> 't -> ((_,'x,_) t as 't)
val continue2 :
  ('a -> 'b -> 't -> 't) ->
  'a -> 'b -> 'x -> 't -> ((_,'x,_) t as 't)
val continue3 :
  ('a -> 'b -> 'c -> 't -> 't) ->
   'a -> 'b -> 'c -> 'x -> 't -> ((_,'x,_) t as 't)

val icontinue1 :
  ('i -> 't -> 't) ->
  'i -> 'x -> 't -> (('i,'x,_) t as 't)
val icontinue2 :
  ('i -> 'a -> 't -> 't) ->
  'i -> 'a -> 'x -> 't -> (('i,'x,_) t as 't)
val icontinue3 :
  ('i -> 'a -> 'b -> 't -> 't) ->
  'i -> 'a -> 'b -> 'x -> 't -> (('i,'x,_) t as 't)

val ifoldx : 't ref -> 'i -> 'a -> 't -> (('i,'a,_) t as 't)
val foldx : 't ref -> 't -> 'a -> ((_,'a,_) t as 't)

(*__________________________________________________________________________*)

val getchar : (_,char,char) t

val getline : (_,char,string) t

