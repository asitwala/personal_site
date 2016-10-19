module PenTool where 

import Html exposing (..)
import Html.Attributes exposing (checked)
import Html.Events exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Window
import Mouse
import Signal
import List
import String
import ModelHelpers exposing (..)
import DrawingHelpers exposing (..)
import ViewHelpers exposing (..)


type alias Point = (Int, Int)


type alias CtrlPoint = 
    { top: Point
    , bottom: Point}


type PenChoice
    = Path
    | Handle
    | Points 


type alias Color = 
    { red: String
    , green: String
    , blue: String
    , opacity: String
    , opacity_slider: String}


type alias Display = 
    { penOption: PenChoice
    , showAllHandles: Bool
    , showAllPoints: Bool
    , canvasColor: Color
    , pathColor: Color
    , pointColor: Color
    , handleColor: Color
    , pathStroke: String
    , pointStroke: String
    , showPractice: Bool
    }

type MouseState 
    = Down 
    | Up


type MouseAction
    = Moving 
    | Stopped 

-- in the case where we delete control points,
-- set them to be the original point 
-- don't deal with Maybe 

type alias State = 
    { points: List Point
    , paths: List Svg.Svg
    , allPaths: List (List Svg.Svg)
    , controlPoints: List CtrlPoint
    , mouseState: MouseState
    , mouseAction: MouseAction
    , currentPoint: Maybe Point
    , lastPoint: Maybe Point
    , ctrlCurrentPoint: Maybe CtrlPoint
    , ctrlLastPoint: Maybe CtrlPoint
    , displays: Display
    }


 -- referencing the TodoMVC example
type Action
    = Clear
    | MouseDown MouseState Point 
    | MouseMove MouseAction Point 
    | MouseUp MouseState Point
    | ShowHandles Bool
    | ShowPoints Bool
    | ShowPractice Bool 
    | ChangeCanvasColor String String
    -- (String, String): ("red", "255")
    | ChangePathColor String String
    | ChangePointColor String String
    | ChangeHandleColor String String
    | ChangePathStroke String
    | ChangePointStroke String
    | ChangePenOption PenChoice   
    | Undo
    | Finish



initCanvasColor = (changeColor "255" "255" "255" "1.0" "100")
initPathColor = (changeColor "67" "2" "70" "1.0" "100")
initPointColor = (changeColor "0" "0" "0" "1.0" "100")
initHandleColor = (changeColor "222" "95" "0" "1.0" "100")



initState: State
initState = 
    { points = []
    , paths = []
    , allPaths = [] 
    , controlPoints = []
    , mouseState = Up
    , mouseAction = Stopped -- default, mouse is always stopped -- only is moving when mouseMove event is triggered
    , currentPoint = Nothing
    , lastPoint = Nothing
    , ctrlCurrentPoint = Nothing
    , ctrlLastPoint = Nothing
    , displays = 
        { penOption = Path
        , showAllHandles = False
        , showAllPoints = True
        , canvasColor = initCanvasColor
        , pathColor = initPathColor
        , pointColor = initPointColor
        , handleColor = initHandleColor
        , pathStroke = "1"
        , pointStroke = "3"
        , showPractice = False
        }
    }



upstate: Action -> State -> State
upstate e i = 
    case e of 
        Clear -> {i| points = []
                , paths = []
                , allPaths = []
                , controlPoints = []
                , mouseState = Up
                , mouseAction = Stopped
                , currentPoint = Nothing
                , lastPoint = Nothing
                , ctrlCurrentPoint = Nothing
                , ctrlLastPoint = Nothing}
        MouseDown m t -> 
            if (m == Down) then 
                {i| points = t::(i.points)
                , mouseState = m
                , mouseAction = Stopped
                , paths = i.paths
                , controlPoints = i.controlPoints
                , currentPoint = Just t 
                , lastPoint = i.currentPoint
                -- initialize control points to just be the original point 
                -- last point becomes updated -- both the point and control points
                , ctrlCurrentPoint = Nothing
                , ctrlLastPoint = i.ctrlCurrentPoint
                , displays = i.displays
                }
            else 
                {i| mouseState = m, mouseAction = Stopped} -- don't care if moving since drawing handles is taken care of in "view"

        MouseMove a t -> 
            {i| mouseAction = a}


        MouseUp m l -> 
            if (i.mouseState == Down && i.mouseAction == Moving) then 
                {i|points = i.points
                , mouseState = m
                , mouseAction = Stopped 
                , paths = (drawPaths i.displays.pathStroke i.displays.pathColor 
                    ({top = (getReflection (fromJust i.currentPoint) l), bottom = l}::i.controlPoints) i.points)
                , controlPoints = 
                    {top = (getReflection (fromJust i.currentPoint) l), bottom = l}::i.controlPoints
                , currentPoint = i.currentPoint
                , lastPoint = i.lastPoint
                , ctrlCurrentPoint = 
                    Just {top = (getReflection (fromJust i.currentPoint) l), bottom = l}
                , ctrlLastPoint = i.ctrlCurrentPoint
                , displays = i.displays
                }
            else if (i.mouseState == Down && i.mouseAction == Stopped) then 
                -- most of these cases are handled by mouseDown in terms of points
                 {i| points = i.points
                , mouseState = m
                , mouseAction = Stopped 
                , paths = (drawPaths i.displays.pathStroke i.displays.pathColor 
                    ({top = l, bottom = l}::i.controlPoints) i.points)
                , controlPoints = {top = l, bottom = l}::i.controlPoints
                , currentPoint = i.currentPoint
                , lastPoint = i.lastPoint
                , ctrlCurrentPoint = 
                    Just {top = l, bottom = l}
                , ctrlLastPoint = i.ctrlLastPoint
                , displays = i.displays
                }
            else 
                {i| mouseState = m, mouseAction = Stopped}


        ShowHandles b -> 
            let 
                d = i.displays
                new = {d| showAllHandles = b}
            in 
            {i| displays = new}

        ShowPoints b -> 
            let 
                d = i.displays
                new = {d| showAllPoints = b}
            in 
            {i| displays = new}

        ShowPractice b -> 
            let 
                d = i.displays
                new = {d| showPractice = b}
            in 
            {i| displays = new}
        
        ChangeCanvasColor t v -> 
            let 
                d = i.displays.canvasColor
                d1 = i.displays
                helper d t v = 
                    if (t == "red") then
                        {d1| canvasColor = 
                            changeColor v d.green d.blue d.opacity d.opacity_slider}
                    else if (t == "green") then
                        {d1| canvasColor = 
                            changeColor d.red v d.blue d.opacity d.opacity_slider}
                    else if (t == "blue") then 
                        {d1| canvasColor = 
                            changeColor d.red d.green v d.opacity d.opacity_slider}
                    else -- if t == opacity 
                        {d1| canvasColor = 
                            changeColor d.red d.green d.blue (toString((fromResult (String.toFloat v))/100)) v}
            in 
            {i| displays = (helper d t v)}

        ChangePathColor t v -> 
            let 
                dis = i.displays.pathColor
                d1 = i.displays

                colorOpt d str val = 
                    if (str == "red") then 
                        changeColor val d.green d.blue d.opacity d.opacity_slider
                    else if (str == "green") then 
                       changeColor d.red val d.blue d.opacity d.opacity_slider
                    else if (str == "blue") then 
                        changeColor d.red d.green val d.opacity d.opacity_slider
                    else -- it t == opacity
                        changeColor d.red d.green d.blue (toString((fromResult (String.toFloat val))/100)) val

                helper d str val = 
                    {d1| pathColor = (colorOpt d str val)}
            in 
            {i| paths = (drawPaths i.displays.pathStroke (colorOpt dis t v) i.controlPoints i.points), displays = (helper dis t v)}

        ChangePointColor t v -> 
            let 
                d = i.displays.pointColor
                d1 = i.displays
                helper d t v = 
                    if (t == "red") then
                        {d1| pointColor = 
                            changeColor v d.green d.blue d.opacity d.opacity_slider}
                    else if (t == "green") then
                        {d1| pointColor = 
                            changeColor d.red v d.blue d.opacity d.opacity_slider}
                    else if (t == "blue") then 
                        {d1| pointColor = 
                            changeColor d.red d.green v d.opacity d.opacity_slider}
                    else -- if t == opacity 
                        {d1| pointColor = 
                            changeColor d.red d.green d.blue (toString((fromResult (String.toFloat v))/100)) v}
            in 
            {i| displays = (helper d t v)}
        
        ChangeHandleColor t v -> 
            let 
                d = i.displays.handleColor
                d1 = i.displays
                helper d t v = 
                    if (t == "red") then
                        {d1| handleColor = 
                            changeColor v d.green d.blue d.opacity d.opacity_slider}
                    else if (t == "green") then
                        {d1| handleColor = 
                            changeColor d.red v d.blue d.opacity d.opacity_slider}
                    else if (t == "blue") then 
                        {d1| handleColor = 
                            changeColor d.red d.green v d.opacity d.opacity_slider}
                    else -- if t == opacity 
                        {d1| handleColor = 
                            changeColor d.red d.green d.blue (toString((fromResult (String.toFloat v))/100)) v}
            in 
            {i| displays = (helper d t v)}

        ChangePathStroke w -> 
            let 
                d = i.displays
                new = {d| pathStroke = w}
            in 
            {i| paths = (drawPaths w i.displays.pathColor i.controlPoints i.points), displays = new}

        ChangePointStroke w -> 
            let 
                d = i.displays
                new = {d| pointStroke = w}
            in 
            {i| displays = new}

        ChangePenOption o -> 
            let 
                d = i.displays
                new = {d| penOption = o}
            in 
            {i| displays = new}

        Undo -> 
            case i.points of 
                [] -> i
                x::[] -> 
                    {i| points = []
                    , paths = []
                    , mouseState = Up
                    , mouseAction = Stopped
                    , controlPoints = []
                    , currentPoint = Nothing
                    , lastPoint = Nothing
                    , ctrlCurrentPoint = Nothing
                    , ctrlLastPoint = Nothing}
                x::y::[] -> 
                    {i| points = y::[]
                    , paths = (drawPaths i.displays.pathStroke i.displays.pathColor (List.drop 1 i.controlPoints) (List.drop 1 i.points))
                    , mouseState = Up
                    , mouseAction = Stopped
                    , controlPoints = List.drop 1 i.controlPoints
                    , currentPoint = i.lastPoint
                    , lastPoint = Nothing
                    , ctrlCurrentPoint = i.ctrlLastPoint
                    , ctrlLastPoint = Nothing}
                _ -> 
                    {i| points = (List.drop 1 i.points)
                    , paths = (drawPaths i.displays.pathStroke i.displays.pathColor (List.drop 1 i.controlPoints) (List.drop 1 i.points))
                    , mouseState = Up
                    , mouseAction = Stopped
                    , controlPoints = List.drop 1 i.controlPoints
                    , currentPoint = i.lastPoint
                    , lastPoint = Just (getListElement 2 i.points)
                    , ctrlCurrentPoint = i.ctrlLastPoint
                    , ctrlLastPoint = Just (getListElement 2 i.controlPoints)
                    }

        Finish -> 
            {i| points = []
                , paths = []
                , allPaths = i.paths::(i.allPaths)
                , controlPoints = []
                , mouseState = Up
                , mouseAction = Stopped
                , currentPoint = Nothing
                , lastPoint = Nothing
                , ctrlCurrentPoint = Nothing
                , ctrlLastPoint = Nothing}


-- setting up the Action mailbox 
actionMailbox: Signal.Mailbox Action
actionMailbox = Signal.mailbox Clear

stateOverTime: Signal State
stateOverTime = Signal.foldp upstate initState actionMailbox.signal

---------------------------------------------------------------

view: State -> (Int, Int) -> Point -> Html
view i (w,h) (pos_x, pos_y) = 
    let
        -- SET UP CANVAS BASED ON WINDOW --
        wid = toString w
        ht = toString (round(0.70 * (toFloat h)))
        ht_num = (round(0.70 * (toFloat h)))
        canvas_1 = Svg.svg [width wid, height ht, viewBox "0 0 w ht_num"]


        -- SET-UP GUI -------------------------------------------------------------------------------------------------------

        -- checkboxes:
        checkBoxHandles = checkbox actionMailbox.address i.displays.showAllHandles (ShowHandles)
        checkBoxPoints = checkbox actionMailbox.address i.displays.showAllPoints (ShowPoints)
        checkBoxPractice = checkbox actionMailbox.address i.displays.showPractice (ShowPractice)


        -- sliders: 

        -- CANVAS RGBA: 

        sliderCanvasRed = slider "0" "255" actionMailbox.address (i.displays.canvasColor.red) (ChangeCanvasColor "red")
        sliderCanvasGreen = slider "0" "255" actionMailbox.address (i.displays.canvasColor.green) (ChangeCanvasColor "green")
        sliderCanvasBlue = slider "0" "255" actionMailbox.address (i.displays.canvasColor.blue) (ChangeCanvasColor "blue")
        sliderCanvasOpacity = slider "0" "100" actionMailbox.address (i.displays.canvasColor.opacity_slider) (ChangeCanvasColor "opacity")

        -- POINTS: 
        sliderPointRed = slider "0" "255" actionMailbox.address (i.displays.pointColor.red) (ChangePointColor "red")
        sliderPointGreen = slider "0" "255" actionMailbox.address (i.displays.pointColor.green) (ChangePointColor "green")
        sliderPointBlue = slider "0" "255" actionMailbox.address (i.displays.pointColor.blue) (ChangePointColor "blue")
        sliderPointOpacity = slider "0" "100" actionMailbox.address (i.displays.pointColor.opacity_slider) (ChangePointColor "opacity")
        sliderPointStroke = slider "0" "20" actionMailbox.address (i.displays.pointStroke) (ChangePointStroke)

        -- PATHS: 
        sliderPathRed = slider "0" "255" actionMailbox.address (i.displays.pathColor.red) (ChangePathColor "red")
        sliderPathGreen = slider "0" "255" actionMailbox.address (i.displays.pathColor.green) (ChangePathColor "green")
        sliderPathBlue = slider "0" "255" actionMailbox.address (i.displays.pathColor.blue) (ChangePathColor "blue")
        sliderPathOpacity = slider "0" "100" actionMailbox.address (i.displays.pathColor.opacity_slider) (ChangePathColor "opacity")
        sliderPathStroke = slider "0" "20" actionMailbox.address (i.displays.pathStroke) (ChangePathStroke)

        -- HANDLES: 
        sliderHandleRed = slider "0" "255" actionMailbox.address (i.displays.handleColor.red) (ChangeHandleColor "red")
        sliderHandleGreen = slider "0" "255" actionMailbox.address (i.displays.handleColor.green) (ChangeHandleColor "green")
        sliderHandleBlue = slider "0" "255" actionMailbox.address (i.displays.handleColor.blue) (ChangeHandleColor "blue")
        sliderHandleOpacity = slider "0" "100" actionMailbox.address (i.displays.handleColor.opacity_slider) (ChangeHandleColor "opacity")


        -- BUTTONS: 
        buttonPath = mkbutton actionMailbox.address "PATHS" (ChangePenOption Path)
        buttonPoints = mkbutton actionMailbox.address "POINTS" (ChangePenOption Points)
        buttonHandle = mkbutton actionMailbox.address "HANDLES" (ChangePenOption Handle)


        buttonUndo = mkbutton actionMailbox.address "UNDO (current path)" (Undo)
        buttonFinish = mkbutton actionMailbox.address "END" (Finish)
        buttonClear = mkbutton actionMailbox.address "CLEAR CANVAS" (Clear)

        -- IMAGES: 
        imgPenToolRed = icon "penToolRed.png"
        imgPenToolGreen = icon "penToolGreen.png"
        imgPenToolBlue = icon "penToolBlue.png"

        imgCanvasRed = icon "canvasRed.png"
        imgCanvasGreen = icon "canvasGreen.png"
        imgCanvasBlue = icon "canvasBlue.png"



        -- CANVAS ELEMENTS: 
                -- ACTUAL CANVAS COMPONENTS ---------------------------------------------

        -- canvas: 

        renderCanvas = 
            drawRectangle i.displays.canvasColor (w - 2) (ht_num - 2)


        renderPic = 
            if (i.displays.showPractice == True) then 
                [Svg.image [height "100%", width "100%", xlinkHref "exercise.png"] []]
            else 
                []

        -- points:
        renderPoints = 
            if (i.displays.showAllPoints == True) then 
                drawPoints i.displays.pointColor i.displays.pointStroke i.points
            else 
                []

        -- paths: 

            -- mouseExtension: 

        renderExt = 
            if (pos_y > ht_num) then 
                [] 
            else 
                case i.mouseState of 
                    Up -> 
                        case (i.ctrlCurrentPoint) of 
                            Nothing -> [] 
                            _ -> 
                                let 
                                    unwrap = fromJust (i.ctrlCurrentPoint)
                                    bottomCtrlPt = unwrap.bottom
                                in 
                                    drawPath i.displays.pathStroke i.displays.pathColor (fromJust(i.currentPoint), (pos_x, pos_y)) (bottomCtrlPt, (pos_x, pos_y))

                    _ -> []

                -- current Path: 

        renderCurve = 
            case (i.ctrlLastPoint, i.ctrlCurrentPoint) of 
                (Nothing, _) -> []
                (_, Nothing) ->
                    let 
                        cp1 = fromJust i.ctrlLastPoint
                        lastPt = fromJust (i.lastPoint)
                        currPt = fromJust (i.currentPoint)
                    in 
                    if (i.mouseState == Down && i.mouseAction == Moving) then
                        drawCurveInit i.displays.pathStroke i.displays.pathColor (cp1, {top = (getReflection currPt (pos_x, pos_y)), bottom = (pos_x, pos_y)}) (lastPt, currPt)
                    else 
                        []   
                (_, _) -> []

        ---- handles: 

        ----returns a List Svg
        renderCPHandle = 
            case (i.ctrlCurrentPoint) of 
                -- case where you're dragging the mouse
                Nothing -> 
                    if (i.mouseState == Down && i.mouseAction == Moving) then 
                        drawHandle i.displays.handleColor (pos_x, pos_y) (getReflection (fromJust (i.currentPoint)) (pos_x, pos_y))
                    else 
                        []
                _ -> 
                    let 
                        unwrap = fromJust (i.ctrlCurrentPoint)
                    in 
                        drawHandle i.displays.handleColor (unwrap.top) (unwrap.bottom)
                    
                  
        renderLPHandle = 
            case (i.ctrlLastPoint) of 
                Nothing -> []
                _ -> 
                    let 
                        unwrap = fromJust (i.ctrlLastPoint)
                    in 
                        drawHandle i.displays.handleColor (unwrap.top) (unwrap.bottom)


        renderHandles = 
            if (i.displays.showAllHandles == True) then 
                -- drop the first two because they are covered by 
                -- renderCPHandle and renderLPHandle
                drawHandles i.displays.handleColor (i.controlPoints)
            else 
                []


        -- FINAL LIST OF THINGS TO RENDER 
        renderObjects = 
            ([renderCanvas] ++ renderPic ++ renderHandles ++ renderLPHandle ++ renderCPHandle
                ++ renderExt ++ renderCurve ++ i.paths ++ (List.concat i.allPaths)
                ++ renderPoints)


        -- HTML EVENTS: 
        event_1 = Html.Events.onMouseDown actionMailbox.address (MouseDown Down (pos_x, pos_y))
        event_2 = Html.Events.onMouseMove actionMailbox.address (MouseMove Moving (pos_x, pos_y))
        event_3 = Html.Events.onMouseUp actionMailbox.address (MouseUp Up (pos_x, pos_y))
        --event_4 = Html.Events.onKeyPress actionMailbox.address

        -- HTML OBJECTS: 

        canvas_div = 
            Html.div 
            [class "canvasGUI"]
            [Html.h2 [] [Html.text "Canvas ", 
             buttonFinish, buttonUndo, buttonClear]
            , Html.text "Opacity  ", Html.span [] [Html.text "|"], sliderCanvasOpacity
            , Html.p [iconStyle] [imgCanvasRed, imgCanvasGreen, imgCanvasBlue]
            , Html.p [] 
                [sliderCanvasRed, sliderCanvasGreen, sliderCanvasBlue]
            , Html.p [] 
                [Html.text "Show All Handles  ", checkBoxHandles
                ,Html.text "Show All Points  ", checkBoxPoints
                ,Html.text "Show Exercise", checkBoxPractice]]

        penchoice_div = 
            case i.displays.penOption of 
                Path -> 
                    Html.div 
                    [class "pathGUI"]
                    [Html.text "Path Opacity ", Html.span [] [Html.text "|"], sliderPathOpacity 
                    , Html.p [iconStyle] [imgPenToolRed, imgPenToolGreen, imgPenToolBlue]
                    , Html.p [] 
                        [sliderPathRed, sliderPathGreen, sliderPathBlue]
                    , Html.p [] 
                        [Html.text "Stroke Weight ", Html.span [] [Html.text "|"], sliderPathStroke]]
                Points -> 
                    Html.div 
                    [class "pointsGUI"]
                    [Html.text "Point Opacity ", Html.span [] [Html.text "|"], sliderPointOpacity 
                    , Html.p [iconStyle] [imgPenToolRed, imgPenToolGreen, imgPenToolBlue]
                    , Html.p [] 
                        [sliderPointRed, sliderPointGreen, sliderPointBlue]
                    , Html.p [] 
                        [Html.text "Point Size ", Html.span [] [Html.text "|"], sliderPointStroke]]
                Handle -> 
                    Html.div 
                    [class "handleGUI"]
                    [Html.text "Handle Opacity ", Html.span [] [Html.text "|"], sliderHandleOpacity 
                    , Html.p [iconStyle] [imgPenToolRed, imgPenToolGreen, imgPenToolBlue]
                    , Html.p [] 
                        [sliderHandleRed, sliderHandleGreen, sliderHandleBlue]
                    , Html.p [] 
                        [Html.text "Drag the mouse to have handles appear."]]

        pen_div = 
            Html.div
            [class "penGUI"]
            [Html.h2 [] [Html.text "Pen ",
            buttonPath, buttonPoints, buttonHandle]
            , penchoice_div]

        refresh_p = 
            Html.p [id "refresh"] 
            [Html.text "Please refresh the page when you resize the window for proper functionality. | See footer for credits."]


        renderDiv event = 
            Html.div
            event
            [canvas_1 renderObjects, refresh_p
            , Html.div
                [Html.Attributes.style [("display", "flex"), ("flex-direction", "row")
                , ("flex-wrap", "wrap"), ("justify-content", "space-around")]]
                [canvas_div, pen_div]]
                    

    in 
        if (pos_y > ht_num) then 
            renderDiv []
        else 
            renderDiv [event_1, event_2, event_3]


main: Signal Html
main = Signal.map3 view stateOverTime Window.dimensions Mouse.position










