module ModelHelpers where 

import List
import Svg exposing (..)
import Svg.Attributes exposing (..)

type alias Point = (Int, Int)

type alias CtrlPoint = 
    { top: Point
    , bottom: Point}


-- HELPER FUNCTIONS ---------------------------

-- gets a reflection of the point
-- where p1 is the central point 

getReflection: Point -> Point -> Point 
getReflection p1 p2 = 
    let
        x_dst = (fst p1) - (fst p2)
        y_dst = (snd p1) - (snd p2)
    in 
        ((fst p1) + x_dst, (snd p1) + y_dst)

getHead: List a -> a
getHead lst = 
    case lst of
        [] -> Debug.crash "getHead: List is empty"
        x::xs -> x

getListElement: Int -> List a -> a
getListElement pos lst = 
    case lst of 
        [] -> Debug.crash "getListElement: List is empty"
        x::xs -> 
            if (pos == 0) then 
                x
            else 
                (getListElement (pos - 1) xs)

fromJust: Maybe a -> a
fromJust mx = 
    case mx of 
        Nothing -> Debug.crash "fromJust: Input is Nothing"
        Just x -> x


fromResult: Result String a -> a
fromResult a = 
    case a of 
        Ok a' -> a'
        Err b -> Debug.crash "fromResult"



