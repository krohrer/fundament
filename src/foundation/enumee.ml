type ('a,'b) t = continue:'a -> 'b -> 'a

let fold' f =
  fun ~continue b a -> continue (f a b)

let fold1 f =
  fun ~continue b s1 a -> continue s1 (f a b)

let fold2 f =
  fun ~continue b s1 s2 a -> continue s1 s2 (f a b)

let fold3 f =
  fun ~continue b s1 s2 s3 a -> continue s1 s2 s3 (f a b)

let iter' f =
  fun ~continue b a -> f b; continue a

let iter1 f =
  fun ~continue b s1 a -> f b; continue s1 a

let iter2 f =
  fun ~continue b s1 s2 a -> f b; continue s1 s2 a

let iter3 f =
  fun ~continue b s1 s2 s3 a -> f b; continue s1 s2 s3 a

module Rec =
  struct
    type ('a,'b) t = continue:(('a,'b) t -> 'a) -> 'b -> 'a

    let fold' f =
      let rec re ~continue b a = continue re (f a b) in
      re

    let fold1 f =
      let rec re ~continue b a s1 = continue re (f a b) s1 in
      re

    let fold2 f =
      let rec re ~continue b a s1 s2 = continue re (f a b) s1 s2 in
      re

    let fold3 f =
      let rec re ~continue b a s1 s2 s3 = continue re (f a b) s1 s2 s3 in
      re
  end

module Rec2 =
  struct
    type ('a,'b) t = continue:(('a,'b) t -> 'a -> 'a) -> 'b -> 'a

    let iter' f =
      let stop = () in
      let rec re ~continue b = f b; continue re stop in
      re

    let iter1 f =
      let stop _ = () in
      let rec re ~continue b s1 = f b; continue re stop s1 in
      re

    let iter2 f =
      let stop _ _ = () in
      let rec re ~continue b s1 s2 = f b; continue re stop s1 s2 in
      re

    let any_of' f =
      let stop = false in
      let rec re ~continue b = if f b then true else continue re stop in
      re

    let any_of1 f =
      let stop _ = false in
      let rec re ~continue b s1 = if f b then true else continue re stop s1 in
      re

    let all_of' f =
      let stop = true in
      let rec re ~continue b = if f b then true else continue re stop in
      re

    let all_of1 f =
      let stop _ = true in
      let rec re ~continue b s1 = if f b then true else continue re stop s1 in
      re
  end

