-- Note: Received help from Amanda Aizuss about generating
-- different seeds for x and y in "genPoint"

module Pi where

import Random
import Signal
import Graphics.Element exposing (..)
import String
import Window
import Time
import Color exposing (..)
import Graphics.Collage exposing (..)
import Text
import List 

type alias Point = { x:Float, y:Float }

type alias State = ((Int, List Point), (Int, List Point))

initState = ((0,[]), (0,[]))

upstate : Point -> State -> State
upstate pt st =

  -- we are using the unit square/circle
  -- equation for checking that the point is inside the circle boundary
  -- x^2 + y^2 <= r^2
  -- in this case:
  -- x^2 + y^2 <= 1

  let 
    x_sqr = ((pt.x) ^ 2)
    y_sqr = ((pt.y) ^ 2)
    hits = fst(fst st)
    hit_list = snd(fst st)
    misses = fst(snd st)
    miss_list = snd(snd st)
  in 
    if ((x_sqr + y_sqr) <= 1) then
      ((hits + 1, pt::hit_list), (misses, miss_list))
    else
      ((hits, hit_list), (misses + 1, pt::miss_list))   


inRange: Point -> Bool
inRange pt = 
  let
    x_1 = 0.25
    x_2 = 0.35
    x_3 = 0.50
    y_1 = 0.40
    y_2 = 0.30
    case_1 = (pt.x >= -x_2) && (pt.x <= -x_1)
    case_2 = (pt.y >= -y_1) && (pt.y <= y_1)
    case_3 = (pt.x >= x_1) && (pt.x <= x_2)
    case_4 = (pt.x >= -x_3) && (pt.x <= x_3) && (pt.y >= y_2) && (pt.y <= y_1)
  
  in
  if((case_1 && case_2) || (case_3 && case_2) || case_4) then
    True
  else
    False

not_inRange: Point -> Bool
not_inRange pt = 
  let
    x_1 = 0.25
    x_2 = 0.35
    x_3 = 0.50
    y_1 = 0.40
    y_2 = 0.30
    case_1 = (pt.x >= -x_2) && (pt.x <= -x_1)
    case_2 = (pt.y >= -y_1) && (pt.y <= y_1)
    case_3 = (pt.x >= x_1) && (pt.x <= x_2)
    case_4 = (pt.x >= -x_3) && (pt.x <= x_3) && (pt.y >= y_2) && (pt.y <= y_1)
    
  in
  if((case_1 && case_2) || (case_3 && case_2) || case_4) then
    False
  else
    True


view : (Int,Int) -> State -> Element
view (w,h) st =
  let 
    color_1 = rgba 0 0 255 0.4
    color_1a = rgba 0 0 255 0.12
    color_2 = rgba 255 128 0 0.1
    color_3 = rgba 255 128 0 0.5
    color_4 = rgba 50 45 127 0.85
    color_5 = rgba 255 128 0 0.8
    

    --updates
    color_1_up = rgba 0 0 255 0.3


    form_2 = outlined (dotted Color.blue) (circle 200)
    form_3 = outlined (dotted Color.orange) (rect 400 400)
    form_4 = filled color_2 (rect 400 400)
    form_5 = filled color_1a (circle 200)

    -- blue is a hit
    hit_list = (snd(fst st))

    pi_list = List.filter inRange hit_list
    cir_list = List.filter not_inRange hit_list

    dark_list = pointsToCircles color_4  4 pi_list
    light_list = pointsToCircles color_1 3 cir_list

    
    -- orange is a miss
    list_2 = pointsToCircles color_3  3 (snd(snd st))

    -- Graphics elements (cannot get under 80 lines without running into whitespace issues)

    title_form = move (0, 280) (toForm(justified(Text.height 24 (Text.bold(Text.fromString ("Approximating the Value of π"))))))

    points_form = move (0, 240) (toForm(justified(Text.fromString("Number of Points Generated "))))

    points_num = move (0, 220) (toForm(justified(Text.height 18 (Text.bold(Text.fromString(toString ((fst(fst st)) + (fst(snd st)))))))))

    hit_form = move (-120, -220) (toForm(rightAligned(Text.fromString("Hits = " ++ (toString(fst(fst st)))))))

    miss_form = move (110, -220) (toForm(rightAligned(Text.fromString("Misses = " ++ (toString(fst(snd st)))))))

    pi_form = move (0, -270) (toForm(justified(Text.color color_4 (Text.height 20 (Text.bold(Text.fromString ("π = " ++ (toString (piApprox st)))))))))

  in 
    (collage w h (form_4::form_5::form_2::form_3::pi_form::hit_form::miss_form::points_num::points_form::title_form::list_2 ++ dark_list ++ light_list))


toPoint: (Float, Float) -> Point
toPoint (a,b) = 
  {x = a, y = b}


genPoint : Random.Seed -> (Point, Random.Seed)
genPoint s =
  let 
    output_1 = Random.generate (Random.float -1.0 1.0) s
    output_2 = Random.generate (Random.float -1.0 1.0) (snd output_1)
  in 
    ({x = (fst output_1), y = (fst output_2)}, (snd output_2))


-- signal of type (Point, Random.Seed)
-- use the Time library to define a "ticking clock" and then the Signal.foldp
-- to turn this ticker into a signal that produces values of type 
-- (Point, Random.Seed)

signalPointSeed : Signal (Point, Random.Seed)

signalPointSeed =
  let 
    s = Random.initialSeed 97
    point = {x = 0.0, y = 0.0}
    timer = Time.every 50
  in 
    Signal.foldp (\time point_tuple-> genPoint(snd point_tuple)) (point, s) timer

signalPoint : Signal Point
signalPoint =
  Signal.map fst signalPointSeed



pointsToCircles: Color.Color -> Float -> List Point -> List Form

pointsToCircles col r p_lst = 
  let
    shape_1 = circle r
    form_1 = filled col shape_1
    scale_point pt = 
      (200 * pt.x, 200 * pt.y)
    move_point pt = 
      move (scale_point pt) form_1
  in 
    List.map move_point p_lst


piApprox : State -> Float
piApprox st = 
  let 
    hits = (fst(fst st))//1
    hit_list = (snd(fst st))
    misses = (fst(snd st))//1
    miss_list = (snd(snd st))
    total = toFloat(hits + misses)
  in 
    ((toFloat hits) / total) * 4



main : Signal Element
main =
  Signal.map2 view Window.dimensions
    (Signal.foldp upstate initState signalPoint)