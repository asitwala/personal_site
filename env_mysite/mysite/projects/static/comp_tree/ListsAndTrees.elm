-- Note: Kevin Zen gave me an overview of how to 
-- approach "balancedTrees" and showed me that 
-- (Node x y) can act as a function. He helped me significantly
-- with the helper function "mergeTrees."

module ListsAndTrees where

import List

-- Running Time:
-- "suffixes" takes a list and breaks
-- the list up into head and tail each time
-- the tail decreases by 1 each time and the
-- list passed into the suffixes is constructed onto the 
-- the results from past iterations 

--  (::) takes a constant time
-- Iterate through list n * 1 times = n times
-- "suffixes" is linear in n, where n is the 
-- number of elements in the list 

suffixes: List a -> List (List a)
suffixes xs =
  case xs of 
    [] -> [[]]
    x::xs' -> xs::(suffixes xs')

type Tree = Empty | Node Int Tree Tree


-- From hw2 write-up, "mem x t determines whether x 
-- is contained in the binary search tree t"
-- nodes to the left < root
-- nodes to the right > root

--mem : Int -> Tree -> Bool
--mem x t = 
--  case t of 
--    Empty -> False
--    Node y left right -> 
--      if (x == y) then True
--      else if (x < y) then
--        (mem x left)
--      else 
--        (mem x right)

-- ^ first implementation is the standard way
-- yes, it is O(logn) but it doesn't use at most
-- h+1 comparisons -- would be 2 comparisons per level


-- Running Time: 
-- "mem" traverses one path in the tree 
-- as opposed to all nodes, so it is linear in 
-- height
-- It first compares the given value x to 
-- to the value in the root -- one comparison per each level
-- If less than that value, mem is called on the left tree
-- If greater than that value, mem is called on the right tree

-- this implementation only uses compare and then pattern 
-- matches the result against a series of options for the 
-- type Order 

mem: Int -> Tree -> Bool
mem x t = 
  case t of 
    Empty -> False
    Node y left right -> 
      case (compare x y) of 
        EQ -> True
        LT -> (mem x left)
        GT -> (mem x right)


-- Running Time: 
-- "fullTree" adds a node each level 
-- and then recursively call itself on the left
-- and right subtrees with the original height - 1
-- The running time should be 2*h due to the two recursive
-- calls -> thus fullTree is linear in h, or the
-- height of the tree


fullTree : Int -> Int -> Tree
fullTree x h =
  if (h < 0) then 
    Empty
  else 
    case h of 
      0 -> Empty
      _ -> Node x (fullTree x (h - 1)) (fullTree x (h - 1))

-- Running Time: 
-- "balancedTree" takes a divide and conquer 
-- approach
-- "balancedTree" makes one call on (size-1)//2 to "create2,"
-- which further divides the inputted size in half
-- each time the recursive helper function is called in "create2",
-- it divides the size m by 2
-- Thus, we can clearly see that the running time is linear in 
-- log(base 2) m, where m is the size of the tree 

balancedTree: Int -> Int -> Tree
balancedTree x m = 
  let 
    tree_tuple = (create2 x ((m - 1)//2))
    first = fst(tree_tuple)
    second = snd(tree_tuple)
  in 
    if (m == 0) then 
      Empty
    else if ((m `rem` 2) == 0) then 
      Node x second first
    else
      Node x first first


create2: Int -> Int -> (Tree, Tree)
create2 x m = 
  let 
    helper x m = 
      case m of 
        0 -> Empty 
        1 -> Node x Empty Empty
        _ ->
          if ((m `rem` 2) == 0) then
            Node x (helper x (m//2)) (helper x ((m - 1)//2))
          else 
            Node x (helper x ((m - 1)//2)) (helper x ((m - 1)//2))
  in 
    (helper x m, helper x (m + 1))


-- Don't need to add running times for the rest of the functions: 

mergeTrees: Int -> List Tree -> List Tree -> List Tree
mergeTrees x left right = 
  case left of 
    [] -> []
    y::ys -> (List.map (Node x y) right) ++ (mergeTrees x ys right)


--SECOND PARAMETER = SIZE, NOT HEIGHT!
balancedTrees : Int -> Int -> List Tree
balancedTrees x n =
  case n of 
    0 -> [Empty]
    _ -> 
      let
        list_1 = balancedTrees x (n//2)
        list_2 = balancedTrees x ((n - 1)//2)
      in 
        -- if n is odd, then right and left subtrees are equal
        if ((n `rem` 2) == 1) then
          (mergeTrees x list_1 list_1) 
        else 
        -- if n is even, then right and left subtrees can differ in size 
        -- by 1
          (mergeTrees x list_1 list_2) ++ (mergeTrees x list_2 list_1)
          

--mem for any type of tree, not for BST
isMem : Int -> Tree -> Bool
isMem x t =
  case t of 
    Empty -> False
    Node y left right -> 
      if (x == y) then True
      else ((isMem x left) || (isMem x right))

-- assuming trees are indexed
-- creates an indexed tree
addNode : Int -> Tree -> Tree 
addNode x t = 
  case t of 
    Empty -> Node x Empty Empty
    Node y Empty Empty -> 
      if (x == (2 * y)) then 
        Node y (Node x Empty Empty) Empty
      else if (x == ((2 * y) + 1)) then 
        Node y Empty (Node x Empty Empty)
      else 
        Node y Empty Empty
    Node y left right -> 
      if (isMem (x//2) left) then 
        Node y (addNode x left) right
      else
        Node y left (addNode x right)

-- given a list of integers, creates an indexed tree
addNodes : List Int -> Tree -> Tree
addNodes l t = 
  case l of 
    [] -> t
    x::xs -> (addNodes xs (addNode x t))

-- creates a list of indexed complete trees
iCompleteTrees: Int -> List Tree
iCompleteTrees h = 
  let 
    f_height = h - 1
    last_node = (2^f_height) - 1 
    full_tree = addNodes [1..last_node] Empty
    row_list = List.map (List.reverse) (suffixes (List.reverse([(2^f_height)..((2^h) - 1)])))
    row_length = List.length (row_list)
  in
    if (h == 0) then 
      [Empty]
    else 
      List.drop 1 (List.reverse(List.map2 (addNodes) (row_list) (List.repeat row_length full_tree)))

--changeNode: Int -> Tree -> Tree
--changeNode x t =
--  case t of 
--    Empty -> Empty
--    Node y left right -> 
--      if (x /= y) then 
--        Node x (changeNode x left) (changeNode x right)
--      else 
--        Node y (changeNode x left) (changeNode x right)


completeTrees : Int -> Int -> List Tree
completeTrees x h = 
  let 
    tree_list = iCompleteTrees h 

    change t = 
      case t of
        Empty -> Empty
        Node y left right -> 
          Node x (change left) (change right)

  in 
    List.map (change) tree_list

subsequences: List a -> List (List a)
subsequences xss =
  case xss of
    [] -> [[]]
    x::xs ->
      (List.foldr (\ a b -> a::(x::a)::b) [] (subsequences xs))

-- creates a list of indexed almost complete trees
ialmostCompleteTrees: Int -> List Tree
ialmostCompleteTrees h = 
  let 
    f_height = h - 1
    last_node = (2^f_height) - 1 
    full_tree = addNodes [1..last_node] Empty
    row_list = subsequences[(2^f_height)..((2^h)-1)]
    row_length = List.length(row_list)

  in
    if (h == 0) then 
      [Empty]
    else 
      List.reverse (List.drop 1 (List.reverse (List.map2 (addNodes) (row_list) (List.repeat row_length full_tree))))

-- doesn't work on heights greater than 6
almostCompleteTrees : Int -> Int -> List Tree
almostCompleteTrees x h = 
  let 
    tree_list = ialmostCompleteTrees h 

    change t = 
      case t of
        Empty -> Empty
        Node y left right -> 
          Node x (change left) (change right)

  in 
    List.map (change) tree_list
