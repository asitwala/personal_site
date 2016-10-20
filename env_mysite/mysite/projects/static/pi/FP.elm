-- Note: Kevin Zen gave me a high level overview of "subsequences"

module FP where

import List

digitsOfInt : Int -> List Int

digitsOfInt n =
  if (n < 0) then 
    []
  else 
    let
      a = n `rem` 10
      b = n // 10
    in 
      if ((a == 0) && (b == 0)) then
        [0]
      else if (b == 0) then
        a::[]
      else
        digitsOfInt (n//10) ++ (a::[])


additivePersistence : Int -> Int
--from homework description, "takes positive integer arguments n"

additivePersistence n =
  let 
    a = (List.foldl (+) 0 (digitsOfInt n))

  in
    if ((0 <= n) && (n < 10)) then
      0
    else 
      1 + additivePersistence(a)


digitalRoot : Int -> Int
--from homework description, "takes positive integer arguments n"

digitalRoot n =
  let 
    a = List.foldl (+) 0 (digitsOfInt n)
  in 
    if ((0 <= n) && (n < 10)) then
      n 
    else 
      digitalRoot(a)


-- there will be 2^n subsets of a set 
-- extract the first element and call function on tail
-- add in sublists produced by first element


subsequences: List a -> List (List a)
subsequences xs = 
  let 
    len = List.length xs
    elem_list = List.map2 (::) xs (List.repeat len [])
  in 
    case elem_list of 
      [] -> [[]]
      x::y -> (List.map
       (\lst -> x++lst) (subsequences (List.drop 1 xs)))
        ++ (subsequences (List.drop 1 xs))

   

--take just needs to be a wrapper
take : Int -> List a -> Result String (List a)

take k xs =
  let 
    len = List.length(xs)
  in 
    if (k < 0) then 
      Err "negative index"
    else if (k > len) then 
      Err "not enough elements"
    else
      Ok (List.take k xs)
   

--tried creating take from scratch, but returns Result String (List a)
--take k xs =
  --let 
    --len = List.length (xs)
    --helper n l =  
      --let 
        --head = List.head(l)
        --init_tail = List.tail(l)
        --tail = Maybe.withDefault [] init_tail
      --in 
        --if (n == 0) then 
          --[]
        --else 
          --head :: (helper (n - 1) tail)
  --in 
    --if (k < 0) then 
      --Err "negative index"
    --else if (k > len) then 
      --Err "not enough elements"
    --else
      --Ok (List.take k xs)
      --Ok (helper k xs)


