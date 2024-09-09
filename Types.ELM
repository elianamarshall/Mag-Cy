import GraphicSVG.EllieApp exposing(GetKeyState)

type State 
    = Title
    | CharSelect
    | LevelSelect
    | Game
    | Tutorial
    | Transition State State Float
    | Level Int Float
    | LevelPlaceholder

type GlobalMsg
    = NoMsg
    | InLevelCounter
    | SelectMag
    | SelectCy
    | IconClicked (Float, Float)
    | ClickIcon1
    | ClickIcon2
    | ClickIcon3
    | ClickIcon4
    | ClickIcon5
    | ClickPlatform Int
    | ClickPlatform1
    | ClickPlatform2
    | ClickPlatform3
    | ClickPlatform4
    | ClickPlatform5
    | MagSwitch
    | CySwitch
    | SwitchOff
    
type LocalMsg 
    = Tick Float GetKeyState
    | InLevel
    | DeLevel
    | IncreaseLevel
    | DecreaseLevel
    | HoverOver (Float, Float)
    | LeaveHover
    | HoverMag
    | LeaveMag
    | HoverCy
    | LeaveCy
    | HoverPortal
    | LeavePortal
    | ToChar
    | ToSelect
    | ToGame
    | ToTitle
    | ToTutorial
    | ToPlaceholder
    | ToNextLevel
    | PlayMag
    | PlayCy
    | Waiting

type alias LocalModel = 
    { time : Float 
    , state : State
    , level : Int
    , hoveredButton : (Float, Float)
    , position : (Float, Float)
    , velocity : Float
    , gravity : Float
    , groundLevel : Float
    , topLevel : Float
    , leftBound : Float
    , rightBound : Float
    , jumpHeight : Float
    , magHovered : Bool
    , cyHovered : Bool
    , playingMag : Bool
    , playingCy : Bool
    , torchImage : String
    , torchTimer : Float
    , onFrame : (Float, Float)
    , facingDir : Float
    , jumping : Bool
    , falling : Bool
    , pastHoles : Bool
    , pastPlatforms : Bool
    , portalHovered : Bool 
    , wait : Bool
    , arrowCounter : Int }

type alias GlobalModel = 
    { levelCounter : Int
    , cySelected : Bool
    , magSelected : Bool
    , icon1 : Bool
    , icon2 : Bool
    , icon3 : Bool
    , icon4 : Bool
    , icon5 : Bool
    , platform1 : Bool
    , platform2 : Bool
    , platform3 : Bool
    , platform4 : Bool
    , platform5 : Bool
    , clickedIcon : List (Float, Float)
    , platformColours : List Int
    , switchMagGrav : Bool
    , switchCyGrav : Bool }
