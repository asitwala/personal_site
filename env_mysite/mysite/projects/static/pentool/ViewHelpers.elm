module ViewHelpers where 

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal

type alias Point = (Int, Int)

type alias CtrlPoint = 
    { top: Point
    , bottom: Point}


-- val should be the name of the button 
-- mkbutton instead of button to avoid confusion with other libraries
mkbutton address val action = 
    Html.input 
        [type' "button"
        , value val
        , Html.Events.onClick address action]
        []

-- reference: http://elm-lang.org/examples/checkboxes
checkbox address isChecked action =
    Html.input
        [ type' "checkbox"
        , checked isChecked
        , on "change" targetChecked (Signal.message address << action)
        ]
        []

-- reference: http://stackoverflow.com/questions/33857602/how-to-implement-a-slider-in-elm
-- low and high should be strings
slider low high address val action = 
    Html.input
        [type' "range"
        , Html.Attributes.min low
        , Html.Attributes.max high
        , value val
        , on "input" targetValue (Signal.message address << action)
        ]
        []

-- can check value of val
inputBox address val ne action = 
    Html.input
        [type' "text"
        , value val
        , name ne
        , on "input" targetValue (Signal.message address << action)
        ]
        []

icon name = 
     Html.img [Html.Attributes.src name
     , Html.Attributes.style [("width", "2.25em"), ("height", "2em") 
     ,("margin-top", "-0.5em"), ("margin-bottom", "-0.5em")]][]

iconStyle = 
    Html.Attributes.style [("display", "flex"), ("flex-direction", "row")
                , ("flex-wrap", "wrap"), ("justify-content", "space-around")]



