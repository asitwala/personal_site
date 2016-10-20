--Note: Asked George Teo about Signal.map in "sampleListOn"
--Gave Kevin Zen an overview of how I implemented "drawNodes"
-- and "drawPaths"

module DrawTrees where

import ListsAndTrees exposing (..)

import Signal
import Window
import Mouse
import Text as T
import Graphics.Element as E exposing (..)
import Graphics.Collage as C exposing (..)
import Color exposing (..)

type alias State = List Tree

initState : State
initState = 
  (iCompleteTrees 2)
  ++(iCompleteTrees 3)
  ++(iCompleteTrees 4)
  ++(iCompleteTrees 5)
  ++(iCompleteTrees 6)


extract_head: List a -> a    
extract_head lst = 
  case lst of
    [] -> Debug.crash "extract_head: lst = []"
    y::ys -> y


sampleListOn : Signal b -> List a -> Signal a
sampleListOn ticker xs =
    let 
        update_2 _ lst = 
            case lst of 
                [] -> xs
                y::ys -> ys++[y]
    in 
        (Signal.map (extract_head) (Signal.foldp update_2 xs ticker))


      
drawNodes: Tree -> Float -> Float -> Float -> Float -> List Form
drawNodes t pos_x pos_y dist_x dist_y = 
  let 
    shape_a = outlined (dotted blue) (circle 9)
    shape_b = filled (rgba 142 253 255 0.5) (circle 9)
    shape_c = filled (rgba 6 1 99 0.2) (circle 7.5)
    shape_d = filled (rgba 6 1 99 0.5) (circle 5)
    shape_e = filled (rgba 6 1 99 0.7) (circle 2.5)
    shape_1 = group [shape_a, shape_b, shape_c, shape_d, shape_e]
  in 
      case t of 
        Empty -> []
        Node x Empty Empty -> [move (pos_x, pos_y) shape_1]
        Node x left right -> 
          [move (pos_x, pos_y) shape_1]
          ++(drawNodes left (pos_x - dist_x) (pos_y - dist_y) (dist_x/2) (dist_y*1.2))
          ++(drawNodes right (pos_x + dist_x) (pos_y - dist_y) (dist_x/2) (dist_y*1.2))
          
drawPaths: Tree -> Float -> Float -> Float -> Float -> List (List (Float, Float))        
drawPaths t pos_x pos_y dist_x dist_y = 
     case t of 
        Empty -> [[]]
        Node x Empty Empty -> [[]]
        Node x (Node y Empty Empty) Empty -> 
          [[(pos_x, pos_y), (pos_x - dist_x, pos_y - dist_y)]]
        Node x Empty (Node y Empty Empty) -> 
          [[(pos_x, pos_y), (pos_x + dist_x, pos_y - dist_y)]]
        Node x left right -> 
          [[(pos_x, pos_y), (pos_x - dist_x, pos_y - dist_y)], 
          [(pos_x, pos_y), (pos_x + dist_x, pos_y - dist_y)]]
          ++(drawPaths left (pos_x - dist_x) (pos_y - dist_y) (dist_x/2) (dist_y*1.2))
          ++(drawPaths right (pos_x + dist_x) (pos_y - dist_y) (dist_x/2) (dist_y*1.2))

treeHeight: Tree -> Int
treeHeight t = 
  case t of 
    Empty -> 0
    Node x Empty Empty -> 1
    Node x left right -> 1 + (max (treeHeight left) (treeHeight right))

treeSize: Tree -> Int
treeSize t = 
  case t of 
    Empty -> 0
    Node x Empty Empty -> 1
    Node x left right -> 1 + (treeSize left) + (treeSize right)
          
              
view : (Int,Int) -> Tree -> E.Element
view (w,h) t =

  let 
    node_list = (drawNodes t 0 220 175 62.5)
    path_list_1 = (drawPaths t 0 220 175 62.5)
    path_list_2 = List.map (path) path_list_1
    path_list = List.map (\x -> traced ({ defaultLine | width = 2, color = (rgba 0 165 165 0.6)}) x) path_list_2

    tree_list = path_list ++ node_list
    
    --text/titles

    title_form = 
      move (0, 290)
       <|toForm
       <|justified
       <|T.height 24 
       <|T.bold
       <|T.fromString ("A Visualization of Complete Trees")

    label_form = 
      move (0, 260)
       <|toForm
       <|justified
       <|T.height 14
       <|T.fromString ("Click anywhere on the screen to produce another complete tree.")

    height_form = 
      move (0, -290)
       <|toForm
       <|justified
       <|T.color (rgba 0 165 165 0.7)
       <|T.height 20 
       <|T.bold
       <|T.fromString ("Height of Tree = " ++ (toString (treeHeight t)))

    size_form = 
      move (0, -310)
       <|toForm
       <|justified
       <|T.color (rgba 6 1 99 0.5)
       <|T.height 16
       <|T.bold
       <|T.fromString ("Number of Nodes = " ++ (toString (treeSize t)))

  
  in 
    collage (fst(w,h)) (snd(w,h)) (size_form::height_form::label_form::title_form::tree_list)



  --E.spacer 0 0

signalTree : Signal Tree
signalTree = 
    let 
        ticker = Mouse.clicks
    in 
        sampleListOn ticker initState 

main : Signal E.Element
main =
  Signal.map2 view Window.dimensions signalTree

