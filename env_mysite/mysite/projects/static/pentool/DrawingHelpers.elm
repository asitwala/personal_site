module DrawingHelpers where 

import List
import Svg exposing (..)
import Svg.Attributes exposing (..)
import String



type alias Color = 
    { red: String
    , green: String
    , blue: String
    , opacity: String
    , opacity_slider: String}


type alias Point = (Int, Int)

type alias CtrlPoint = 
    { top: Point
    , bottom: Point}



changeColor: String -> String -> String -> String -> String -> Color
changeColor r g b o os = 
    { red = r
    , green = g
    , blue = b
    , opacity = o
    , opacity_slider = os}


toSVGColor: String -> String -> String -> String -> String 
toSVGColor r g b o = 
    String.join "," ["rgba(" ++ r, g, b, o ++ ")"]


drawRectangle: Color -> Int -> Int -> Svg.Svg
drawRectangle c w h = 
    Svg.rect [fill (toSVGColor c.red c.green c.blue c.opacity), stroke "black", strokeWidth "2", rx "5", ry "5", x "1", y "1", width (toString w), height (toString h)] []


drawHandle: Color -> Point -> Point -> List Svg.Svg
drawHandle c t1 t2 = 
    let 
        x_1 = toString(fst(t1))
        x_2 = toString(fst(t2))
        y_1 = toString(snd(t1))
        y_2 = toString(snd(t2))
        col = (toSVGColor c.red c.green c.blue c.opacity)
    in 
        [Svg.circle [cx x_1, cy y_1, r "3", fill col] [],
        Svg.circle [cx x_2, cy y_2, r "3", fill col] [], 
        Svg.line [x1 x_1, y1 y_1, x2 x_2, y2 y_2, stroke col, strokeWidth "1"] []]

drawHandles: Color -> List CtrlPoint -> List Svg.Svg
drawHandles c lst = 
    let 
        top_list = List.map .top lst
        bottom_list = List.map .bottom lst

    in 
        List.concat(List.map2 (\t1 t2 -> drawHandle c t1 t2) top_list bottom_list)


drawPoint: Color -> String -> Point -> Svg.Svg
drawPoint c size t =
    let 
        x = toString(fst(t))
        y = toString(snd(t))

    in 
        Svg.circle [cx x, cy y, r size, fill (toSVGColor c.red c.green c.blue c.opacity)] []

drawPoints: Color -> String -> List Point -> List Svg.Svg
drawPoints c size lst = 
    List.map (\t -> drawPoint c size t) lst


drawPath: String -> Color -> (Point, Point) -> (Point, Point) -> List Svg.Svg
-- first is a tuple of two points 
-- second is a tuple of control points: 
-- (bottom CtrlPoint of first point) and (top CtrlPoint of second point)

drawPath w c t1 t2 = 
    let 
      pt_1_x = toString(fst(fst t1))
      pt_1_y = toString(snd(fst t1))
      pt_2_x = toString(fst(snd t1))
      pt_2_y = toString(snd(snd t1))
      ctrl_1_x = toString(fst(fst t2))
      ctrl_1_y = toString(snd(fst t2))
      ctrl_2_x = toString(fst(snd t2))
      ctrl_2_y = toString(snd(snd t2))

      data = String.join " " ["M", pt_1_x, pt_1_y, "C", ctrl_1_x, ctrl_1_y,
      ctrl_2_x, ctrl_2_y, pt_2_x, pt_2_y]

    in 
    [Svg.path [d data, fill "none", stroke (toSVGColor c.red c.green c.blue c.opacity), strokeWidth w] []]

--drawCurveInit: State 
drawCurveInit: String -> Color -> (CtrlPoint, CtrlPoint) -> (Point, Point) -> List Svg.Svg
drawCurveInit w c (cLastPt, cCurrPt) (lastPt, currPt) = 
    drawPath w c (lastPt, currPt) (cLastPt.bottom, cCurrPt.top)

takeTwo: List a -> List (a, a)
takeTwo lst = 
    case lst of 
        [] -> []
        x::[] -> []
        x::y::tail -> (x,y)::(takeTwo (y::tail))


drawPaths: String -> Color -> List CtrlPoint -> List Point -> List Svg.Svg
drawPaths w c clst plst = 
  let 
    point_lst = takeTwo (List.reverse plst)
    cpoint_lst = takeTwo (List.reverse clst)
  in 
    List.concat(List.map2 (\t1 t2 -> drawCurveInit w c t1 t2) cpoint_lst point_lst)


