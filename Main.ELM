import Html
import Html.Attributes as HA

magenta = rgb 255 32 234
cyan = rgb 33 250 255
myRed = rgb 255 0  0
myYellow = rgb 253 241 49
myBlue = rgb 0 0 255
myGreen = rgb 0 255 0
myPurple = rgb 194 0 247

cycleColours : List Color
cycleColours =
    [ myRed
      ,
      myYellow
      ,
      myGreen
      ,
      myBlue
      ,
      myPurple
    ]

myShapes localModel globalModel =
    loadFont "https://fonts.googleapis.com/css2?family=Ga+Maamli&family=Irish+Grover&display=swap"
    ::
    case localModel.state of 
      Transition fromState toState k -> (if k < 1.2 then newState fromState localModel globalModel else newState toState localModel globalModel)
                                      ++ [rect 192 300 |> filled black |> move(0, (k-1)^3 * -1000 + 100)]
      Level direction k -> let minK = min 0.25 k
                             in levelSelect localModel
                             ++ [(select (localModel.level - direction) localModel globalModel) |> group |> move (minK * (toFloat direction) * -800, 0)]
                             ++ [(select (localModel.level) localModel globalModel) |> group |> move (minK * (toFloat direction) * -800 + (toFloat direction) * 200, 0)]
      _ -> newState localModel.state localModel globalModel
  
newState state localModel globalModel =
    case state of 
      Title -> title localModel globalModel
      CharSelect -> charSelect localModel globalModel
      LevelSelect -> levelSelect localModel ++ select localModel.level localModel globalModel 
      LevelPlaceholder -> levelPlaceholder localModel
      Tutorial -> tutorial localModel
      _ -> game localModel globalModel

title localModel globalModel =
  [
  html 192 128 (Html.img [HA.width 192, HA.height 128, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/titleBackground.png?raw=true"] [])
  |> move (-96, 64)
  ,
  html 57 93 (Html.img [HA.width 57, HA.height 93, HA.src localModel.torchImage] [])
  |> move (-115, 64)
  |> scale 0.75
  ,
  html 57 93 (Html.img [HA.width 57, HA.height 93, HA.src localModel.torchImage] [])
  |> move (60, 64)
  |> scale 0.75
  ,
  html 57 93 (Html.img [HA.width 57, HA.height 93, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/torch.png?raw=true"] [])
  |> move (-115, 64)
  |> scale 0.75
  ,
  html 57 93 (Html.img [HA.width 57, HA.height 93, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/torch.png?raw=true"] [])
  |> move (60, 64)
  |> scale 0.75
  ,
  button ("Play") (-30,-30) (LocalMsg <| ToChar) (rgb 175 0 154) (rgb 255 32 234) localModel
  ,
  button ("Tutorial") (30,-30) (LocalMsg <| ToTutorial) (rgb 0 170 175) (rgb 33 250 255) localModel
  ,
  if globalModel.magSelected && globalModel.cySelected && localModel.playingMag == False && localModel.playingCy == False then
    [
    rect 192 128
    |> filled (rgb 0 4 52)
    |> makeTransparent 0.5
    ,
    rect 130 30
    |> filled (rgb 0 24 72)
    ,
    text "PLAYER LIMIT REACHED"
    |> customFont "Irish Grover"
    |> centered
    |> bold
    |> size 10
    |> filled (rgb 150 150 175)
    |> move (0, -3)
    ] |> group
  else 
    circle 0 |> filled (rgba 0 0 0 0)
  ]

tutorial localModel =
  [
  html 384 128 (Html.img [HA.width 384, HA.height 128, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/matchingBackground.png?raw=true"] [])
  |> scale 1.5
  |> move (-225, 100) 
  ,
  text "Mag & Cy is a cooperative puzzle-solving game for two"
  |> customFont "Irish Grover"
  |> centered
  |> bold
  |> size 7
  |> filled (rgb 150 150 165)
  |> move (0, 53)
  ,
  text "players, where you'll take on the role of either Mag or Cy."
  |> customFont "Irish Grover"
  |> centered
  |> bold
  |> size 7
  |> filled (rgb 150 150 165)
  |> move (0, 43)
  ,
  text "Use the arrow keys to move and work together to navigate"
  |> customFont "Irish Grover"
  |> centered
  |> bold
  |> size 7
  |> filled (rgb 150 150 165)
  |> move (0, 33)
  ,
  text "unique levels, each offering a different puzzles to"
  |> customFont "Irish Grover"
  |> centered
  |> bold
  |> size 7
  |> filled (rgb 150 150 165)
  |> move (0, 23)
  ,
  text "solve. Success depends on teamwork and communication!"
  |> customFont "Irish Grover"
  |> centered
  |> bold
  |> size 7
  |> filled (rgb 150 150 165)
  |> move (0, 13)
  ,
  html 23 28 (Html.img [HA.width 23, HA.height 28, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/rMag0.png?raw=true"] [])
  |> scale 2
  |> move (-70, 3)
  ,
  html 21 29 (Html.img [HA.width 21, HA.height 29, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/rCy0.png?raw=true"] [])
  |> scale 2
  |> scaleX -1
  |> move (70, 3)
  ,
  button ("Back") (-65,-55) (LocalMsg <| ToTitle) (rgb 175 0 154) (rgb 255 32 234) localModel
  ]
  
game localModel globalModel =
  [
    case localModel.level of
      0 -> group
        [ html 384 128 (Html.img [HA.width 384, HA.height 128, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/matchingBackground.png?raw=true"] [])
          |> scale 1.5
          |> move (-100, 140) 
          |> move localModel.position
          ,
          if localModel.playingMag then
            [
            button ("Level Select") (-65, 55) (LocalMsg <| ToSelect) (rgb 175 0 154) (rgb 255 32 234) localModel
            ,
            html 16 16 (Html.img [HA.width 16, HA.height 16, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/icon1.png?raw=true"] [])
              |> scale 2
              |> move (80, 55)
              |> move localModel.position
            ,
            html 16 16 (Html.img [HA.width 16, HA.height 16, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/icon2.png?raw=true"] [])
              |> scale 2
              |> move (130, 55)
              |> move localModel.position
            ,
            html 16 16 (Html.img [HA.width 16, HA.height 16, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/icon3.png?raw=true"] [])
              |> scale 2
              |> move (180, 55)
              |> move localModel.position
            ,
            html 16 16 (Html.img [HA.width 16, HA.height 16, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/icon4.png?raw=true"] [])
              |> scale 2
              |> move (230, 55)
              |> move localModel.position
            ,
            html 16 16 (Html.img [HA.width 16, HA.height 16, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/icon5.png?raw=true"] [])
              |> scale 2
              |> move (280, 55)
              |> move localModel.position
            ,
            if globalModel.icon1 && globalModel.icon2 && globalModel.icon3 && globalModel.icon4 && globalModel.icon5 then
            html 46 75 (if localModel.portalHovered then (Html.img [HA.width 46, HA.height 75, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/gPinkPortal.png?raw=true"] []) else (Html.img [HA.width 46, HA.height 75, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/oPinkPortal.png?raw=true"] []))
              |> move (325, 50)
              |> move localModel.position
            else circle 0 |> filled (rgba 0 0 0 0)
            ] |> group
          else 
            [
            button ("Level Select") (-65, 55) (LocalMsg <| ToSelect) (rgb 0 170 175) (rgb 33 250 255) localModel
            ,
            html 80 64 (Html.img [HA.width 80, HA.height 64, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/iconGrid.png?raw=true"] [])
            |> move localModel.position
            |> move (150, 80)
            ,
            icon (0, 0) localModel globalModel
            ,
            icon (16, 0) localModel globalModel
            ,
            icon (32, 0) localModel globalModel
            |> notifyTap (GlobalMsg <| ClickIcon4)
            ,
            icon (48, 0) localModel globalModel
            ,
            icon (64, 0) localModel globalModel
            ,
            icon (0, -16) localModel globalModel
            ,
            icon (16, -16) localModel globalModel
            |> notifyTap (GlobalMsg <| ClickIcon1)
            ,
            icon (32, -16) localModel globalModel
            ,
            icon (48, -16) localModel globalModel
            ,
            icon (64, -16) localModel globalModel
            |> notifyTap (GlobalMsg <| ClickIcon5)
            ,
            icon (0, -32) localModel globalModel
            ,
            icon (16, -32) localModel globalModel
            ,
            icon (32, -32) localModel globalModel
            |> notifyTap (GlobalMsg <| ClickIcon2)
            ,
            icon (48, -32) localModel globalModel
            ,
            icon (64, -32) localModel globalModel
            ,
            icon (0, -48) localModel globalModel
            ,
            icon (16, -48) localModel globalModel
            ,
            icon (32, -48) localModel globalModel
            ,
            icon (48, -48) localModel globalModel
            ,
            icon (64, -48) localModel globalModel
            |> notifyTap (GlobalMsg <| ClickIcon3)
            ,
            if globalModel.icon1 && globalModel.icon2 && globalModel.icon3 && globalModel.icon4 && globalModel.icon5 then
            html 46 75 (if localModel.portalHovered then (Html.img [HA.width 46, HA.height 75, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/gBluePortal.png?raw=true"] []) else (Html.img [HA.width 46, HA.height 75, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/oBluePortal.png?raw=true"] []))
              |> move (325, 50)
              |> move localModel.position
            else circle 0 |> filled (rgba 0 0 0 0)
            ] |> group
          ,
          char localModel
          ,
          if localModel.playingMag then 
            button ("Level Select") (-65, 55) (LocalMsg <| ToSelect) (rgb 175 0 154) (rgb 255 32 234) localModel
          else
            button ("Level Select") (-65, 55) (LocalMsg <| ToSelect) (rgb 0 170 175) (rgb 33 250 255) localModel
          ,
          if localModel.wait == False then 
          [
          char localModel 
          ,
          rect 46 46
          |> filled (rgba 0 0 0 0)
          |> move (377, 23)
          |> move localModel.position
          |> notifyEnter (LocalMsg <| HoverPortal)
          |> notifyLeave (LocalMsg <| LeavePortal)
          |> notifyTap (LocalMsg <| Waiting )
          |> notifyTap (GlobalMsg <| InLevelCounter)
          ] |> group
          else
          rect 700 200 |> filled (rgba 0 0 0 0) |> notifyEnter (LocalMsg <| ToPlaceholder)
        ]
      1 -> group
        [ html 384 128 (Html.img [HA.width 384, HA.height 128, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/platformBackground.png?raw=true"] [])
          |> scale 1.5
          |> move (-100, 120) 
          |> move localModel.position
          ,
          if localModel.pastHoles then 
            if localModel.playingCy then
              html 46 75 (if localModel.portalHovered then (Html.img [HA.width 46, HA.height 75, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/gBluePortal.png?raw=true"] []) else (Html.img [HA.width 46, HA.height 75, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/oBluePortal.png?raw=true"] []))
              |> move (353, 45)
              |> move localModel.position
            else
              html 46 75 (if localModel.portalHovered then (Html.img [HA.width 46, HA.height 75, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/gPinkPortal.png?raw=true"] []) else (Html.img [HA.width 46, HA.height 75, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/oPinkPortal.png?raw=true"] []))
              |> move (353, 45)
              |> move localModel.position
          else
            circle 0 
            |> filled (rgba 0 0 0 0)
          ,
          if localModel.playingCy then
            [
            bluePlatform 30 20
            |> move (0, -10)
            |> move localModel.position
            ,
            bluePlatform 30 20
            |> move (30, -10)
            |> move localModel.position
            ,
            bluePlatform 30 20 
            |> move (60, -10)
            |> move localModel.position
            ,
            bluePlatform 30 20 
            |> move (150, -10)
            |> move localModel.position
            ,
            bluePlatform 30 20 
            |> move (240, -10)
            |> move localModel.position
            ,
            bluePlatform 30 20 
            |> move (270, -10)
            |> move localModel.position
            ,
            bluePlatform 30 20 
            |> move (360, -10)
            |> move localModel.position
            ,
            bluePlatform 30 20 
            |> move (390, -10)
            |> move localModel.position
            ] |> group
          else
            [
            pinkPlatform 30 20
            |> move (0, -10)
            |> move localModel.position
            ,
            pinkPlatform 30 20
            |> move (30, -10)
            |> move localModel.position
            ,
            pinkPlatform 30 20
            |> move (60, -10)
            |> move localModel.position
            ,
            pinkPlatform 30 20
            |> move (90, -10)
            |> move localModel.position
            ,
            pinkPlatform 30 20
            |> move (120, -10)
            |> move localModel.position
            ,
            pinkPlatform 30 20
            |> move (150, -10)
            |> move localModel.position
            ,
            pinkPlatform 30 20
            |> move (180, -10)
            |> move localModel.position
            ,
            pinkPlatform 30 20
            |> move (210, -10)
            |> move localModel.position
            ,
            pinkPlatform 30 20
            |> move (240, -10)
            |> move localModel.position
            ,
            pinkPlatform 30 20
            |> move (270, -10)
            |> move localModel.position
            ,
            pinkPlatform 30 20
            |> move (300, -10)
            |> move localModel.position
            ,
            pinkPlatform 30 20
            |> move (330, -10)
            |> move localModel.position
            ,
            pinkPlatform 30 20
            |> move (360, -10)
            |> move localModel.position
            ,
            pinkPlatform 30 20
            |> move (390, -10)
            |> move localModel.position
            ] |> group
          ,
          if localModel.playingMag then 
            button ("Level Select") (-65, 55) (LocalMsg <| ToSelect) (rgb 175 0 154) (rgb 255 32 234) localModel
          else
            button ("Level Select") (-65, 55) (LocalMsg <| ToSelect) (rgb 0 170 175) (rgb 33 250 255) localModel
          ,
          if localModel.wait == False then 
          [
          char localModel 
          ,
          rect 46 46
          |> filled (rgba 0 0 0 0)
          |> move (377, 23)
          |> move localModel.position
          |> notifyEnter (LocalMsg <| HoverPortal)
          |> notifyLeave (LocalMsg <| LeavePortal)
          |> notifyTap (LocalMsg <| Waiting )
          |> notifyTap (GlobalMsg <| InLevelCounter)
          ] |> group
          else
          rect 700 200 |> filled (rgba 0 0 0 0) |> notifyEnter (LocalMsg <| ToPlaceholder)
       ]
      2 -> group
       [
       html 384 128 (Html.img [HA.width 384, HA.height 128, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/matchingBackground.png?raw=true"] [])
       |> scale 1.5
       |> move (-100, 140) 
       |> move localModel.position
       ,
       if localModel.playingMag then 
       [
       colourPlatform 0 50 20 globalModel
       |> move (170, 60)
       |> move localModel.position
       |> notifyTap (GlobalMsg <| ClickPlatform1)
       ,
       colourPlatform 1 20 30 globalModel
       |> move (205, 55)
       |> move localModel.position
       |> notifyTap (GlobalMsg <| ClickPlatform2)
       ,
       colourPlatform 2 20 40 globalModel
       |> move (185, 30)
       |> move localModel.position
       |> notifyTap (GlobalMsg <| ClickPlatform3)
       ,
       colourPlatform 3 30 40 globalModel
       |> move (160, 30) 
       |> move localModel.position
       |> notifyTap (GlobalMsg <| ClickPlatform4)
       ,
       colourPlatform 4 20 30 globalModel
       |> move (205, 25)
       |> move localModel.position
       |> notifyTap (GlobalMsg <| ClickPlatform5)
       ,
       if globalModel.platform1 && globalModel.platform2 && globalModel.platform3 && globalModel.platform4 && globalModel.platform5 then
            html 46 75 (if localModel.portalHovered then (Html.img [HA.width 46, HA.height 75, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/gPinkPortal.png?raw=true"] []) else (Html.img [HA.width 46, HA.height 75, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/oPinkPortal.png?raw=true"] []))
              |> move (325, 50)
              |> move localModel.position
            else circle 0 |> filled (rgba 0 0 0 0)
       ] |> group
       else
       [
       cPlatform myRed 50 20
       |> move (170, 60)
       |> move localModel.position
       ,
       cPlatform myYellow 20 30
       |> move (205, 55)
       |> move localModel.position
       ,
       cPlatform myGreen 20 40
       |> move (185, 30)
       |> move localModel.position
       ,
       cPlatform myBlue 30 40
       |> move (160, 30) 
       |> move localModel.position
       ,
       cPlatform myPurple 20 30
       |> move (205, 25)
       |> move localModel.position
       ,
       if globalModel.platform1 && globalModel.platform2 && globalModel.platform3 && globalModel.platform4 && globalModel.platform5 then
            html 46 75 (if localModel.portalHovered then (Html.img [HA.width 46, HA.height 75, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/gBluePortal.png?raw=true"] []) else (Html.img [HA.width 46, HA.height 75, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/oBluePortal.png?raw=true"] []))
              |> move (325, 50)
              |> move localModel.position
            else circle 0 |> filled (rgba 0 0 0 0)
       ,
       if localModel.playingMag then 
            button ("Level Select") (-65, 55) (LocalMsg <| ToSelect) (rgb 175 0 154) (rgb 255 32 234) localModel
          else
            button ("Level Select") (-65, 55) (LocalMsg <| ToSelect) (rgb 0 170 175) (rgb 33 250 255) localModel
          ,
          if localModel.wait == False then 
          [
          char localModel 
          ,
          rect 46 46
          |> filled (rgba 0 0 0 0)
          |> move (377, 23)
          |> move localModel.position
          |> notifyEnter (LocalMsg <| HoverPortal)
          |> notifyLeave (LocalMsg <| LeavePortal)
          |> notifyTap (LocalMsg <| Waiting )
          |> notifyTap (GlobalMsg <| InLevelCounter)
          ] |> group
          else
          rect 700 200 |> filled (rgba 0 0 0 0) |> notifyEnter (LocalMsg <| ToPlaceholder)
       ] |> group
       ,
       char localModel
       ,
       if localModel.playingMag then 
            button ("Level Select") (-65, 55) (LocalMsg <| ToSelect) (rgb 175 0 154) (rgb 255 32 234) localModel
       else
            button ("Level Select") (-65, 55) (LocalMsg <| ToSelect) (rgb 0 170 175) (rgb 33 250 255) localModel
       ,
       rect 46 46
       |> filled (rgba 0 0 0 0)
       |> move (377, 23)
       |> move localModel.position
       |> notifyEnter (LocalMsg <| HoverPortal)
       |> notifyLeave (LocalMsg <| LeavePortal)
       |> notifyTap (LocalMsg <| ToPlaceholder)
       ]
      3 -> group
       [ html 384 128 (Html.img [HA.width 384, HA.height 128, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/platformBackground.png?raw=true"] [])
          |> scale 1.5
          |> move (-100, 120) 
          |> move localModel.position
          ,
          if localModel.arrowCounter > 2 then 
            if localModel.playingCy then
              html 46 75 (if localModel.portalHovered then (Html.img [HA.width 46, HA.height 75, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/gBluePortal.png?raw=true"] []) else (Html.img [HA.width 46, HA.height 75, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/oBluePortal.png?raw=true"] []))
              |> move (353, 45)
              |> move localModel.position
            else
              html 46 75 (if localModel.portalHovered then (Html.img [HA.width 46, HA.height 75, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/gPinkPortal.png?raw=true"] []) else (Html.img [HA.width 46, HA.height 75, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/oPinkPortal.png?raw=true"] []))
              |> move (353, 45)
              |> move localModel.position
          else
            circle 0 
            |> filled (rgba 0 0 0 0)
          ,
          if localModel.playingCy then
            [
            bluePlatform 30 20
            |> move (0, -10)
            |> move localModel.position
            ,
            bluePlatform 30 20
            |> move (30, -10)
            |> move localModel.position
            ,
            bluePlatform 30 20 
            |> move (120, -10)
            |> move localModel.position
            ,
            bluePlatform 30 20 
            |> move (150, -10)
            |> move localModel.position
            ,
            bluePlatform 30 20 
            |> move (240, -10)
            |> move localModel.position
            ,
            bluePlatform 30 20 
            |> move (270, -10)
            |> move localModel.position
            ,
            bluePlatform 30 20 
            |> move (360, -10)
            |> move localModel.position
            ,
            bluePlatform 30 20 
            |> move (390, -10)
            |> move localModel.position
            ,
            case localModel.arrowCounter of 
              0 -> arrow magenta
                   |> move localModel.position
                   |> move (195, 20)
              1 -> arrow magenta
                   |> move localModel.position
                   |> move (315, 20)
              2 -> arrow magenta
                   |> move localModel.position
                   |> move (75, 20)
              _ -> circle 0 |> filled (rgba 0 0 0 0)
            ] |> group
          else
            [
            pinkPlatform 30 20
            |> move (0, -10)
            |> move localModel.position
            ,
            pinkPlatform 30 20
            |> move (30, -10)
            |> move localModel.position
            ,
            pinkPlatform 30 20 
            |> move (120, -10)
            |> move localModel.position
            ,
            pinkPlatform 30 20 
            |> move (150, -10)
            |> move localModel.position
            ,
            pinkPlatform 30 20 
            |> move (240, -10)
            |> move localModel.position
            ,
            pinkPlatform 30 20 
            |> move (270, -10)
            |> move localModel.position
            ,
            pinkPlatform 30 20 
            |> move (360, -10)
            |> move localModel.position
            ,
            pinkPlatform 30 20 
            |> move (390, -10)
            |> move localModel.position
            ,
            case localModel.arrowCounter of 
              0 -> arrow cyan
                   |> move localModel.position
                   |> move (315, 20)
              1 -> arrow cyan
                   |> move localModel.position
                   |> move (75, 20)
              2 -> arrow cyan
                   |> move localModel.position
                   |> move (195, 20)
              _ -> circle 0 |> filled (rgba 0 0 0 0)
            ] |> group
          ,
          if localModel.playingMag then 
            button ("Level Select") (-65, 55) (LocalMsg <| ToSelect) (rgb 175 0 154) (rgb 255 32 234) localModel
          else
            button ("Level Select") (-65, 55) (LocalMsg <| ToSelect) (rgb 0 170 175) (rgb 33 250 255) localModel
          ,
          if localModel.wait == False then 
          [
          char localModel 
          ,
          rect 46 46
          |> filled (rgba 0 0 0 0)
          |> move (377, 23)
          |> move localModel.position
          |> notifyEnter (LocalMsg <| HoverPortal)
          |> notifyLeave (LocalMsg <| LeavePortal)
          |> notifyTap (LocalMsg <| Waiting )
          |> notifyTap (GlobalMsg <| InLevelCounter)
          ] |> group
          else
          rect 700 200 |> filled (rgba 0 0 0 0) |> notifyEnter (LocalMsg <| ToPlaceholder)
       ]
      _ -> group
       [
       html 384 128 (Html.img [HA.width 384, HA.height 128, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/platformBackground.png?raw=true"] [])
       |> scale 1.5
       |> move (-100, 145) 
       |> move localModel.position
       |> scaleY 1.3
       , 
              if localModel.pastPlatforms then 
            [
            if localModel.playingCy then
              html 46 75 (if localModel.portalHovered then (Html.img [HA.width 46, HA.height 75, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/gBluePortal.png?raw=true"] []) else (Html.img [HA.width 46, HA.height 75, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/oBluePortal.png?raw=true"] []))
              |> scaleY -1
              |> move (333, 65)
              |> move localModel.position
            else
              html 46 75 (if localModel.portalHovered then (Html.img [HA.width 46, HA.height 75, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/gPinkPortal.png?raw=true"] []) else (Html.img [HA.width 46, HA.height 75, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/oPinkPortal.png?raw=true"] []))
              |> scaleY -1
              |> move (333, 65)
              |> move localModel.position
             ] |> group
          else
            circle 0 
            |> filled (rgba 0 0 0 0)
       ,
       if localModel.playingCy then 
         [
         bluePlatform 30 20
         |> move (0, -10)
         |> move localModel.position
         ,
         bluePlatform 30 20
         |> move (30, -10)
         |> move localModel.position
         ,
         gravButton (40, 10) (GlobalMsg <| MagSwitch) magenta (rgb 175 0 154) localModel globalModel |> move localModel.position
         ,
         bluePlatform 30 20
         |> move (45, 125)
         |> move localModel.position
         ,
         bluePlatform 30 20
         |> move (75, 125)
         |> move localModel.position
         ,
         bluePlatform 30 20
         |> move (105, 125)
         |> move localModel.position
         ,
         bluePlatform 30 20
         |> move (135, 125)
         |> move localModel.position
         ,
         bluePlatform 30 20
         |> move (165, 125)
         |> move localModel.position
         ,
         gravButton (175, 145) (GlobalMsg <| MagSwitch) magenta (rgb 175 0 154) localModel globalModel |> move localModel.position
         ,
         bluePlatform 30 20
         |> move (180, -10)
         |> move localModel.position
         ,
         bluePlatform 30 20
         |> move (210, -10)
         |> move localModel.position
         ,
         bluePlatform 30 20
         |> move (240, -10)
         |> move localModel.position
         ,
         bluePlatform 30 20
         |> move (270, -10)
         |> move localModel.position
         ,
         gravButton (280, 10) (GlobalMsg <| MagSwitch) magenta (rgb 175 0 154) localModel globalModel |> move localModel.position
         ,
         bluePlatform 30 20
         |> move (285, 125)
         |> move localModel.position
         ,
         bluePlatform 30 20
         |> move (315, 125)
         |> move localModel.position
         ,
         bluePlatform 30 20
         |> move (345, 125)
         |> move localModel.position
         ,
         bluePlatform 30 20
         |> move (375, 125)
         |> move localModel.position
         ,
         char localModel
         |> scaleY (if globalModel.switchCyGrav then -1 else 1)
         ] |> group
       else 
         [
         pinkPlatform 30 20
         |> move (0, -10)
         |> move localModel.position
         ,
         pinkPlatform 30 20
         |> move (30, -10)
         |> move localModel.position
         ,
         pinkPlatform 30 20
         |> move (45, 125)
         |> move localModel.position
         ,
         pinkPlatform 30 20
         |> move (75, 125)
         |> move localModel.position
         ,
         pinkPlatform 30 20
         |> move (105, 125)
         |> move localModel.position
         ,
         pinkPlatform 30 20
         |> move (135, 125)
         |> move localModel.position
         ,
         pinkPlatform 30 20
         |> move (165, 125)
         |> move localModel.position
         ,
         gravButton (175, 145) (GlobalMsg <| CySwitch) cyan (rgb 0 170 175) localModel globalModel |> move localModel.position
         ,
         pinkPlatform 30 20
         |> move (180, -10)
         |> move localModel.position
         ,
         pinkPlatform 30 20
         |> move (210, -10)
         |> move localModel.position
         ,
         pinkPlatform 30 20
         |> move (240, -10)
         |> move localModel.position
         ,
         pinkPlatform 30 20
         |> move (270, -10)
         |> move localModel.position
         ,
         gravButton (280, 10) (GlobalMsg <| CySwitch) cyan (rgb 0 170 175) localModel globalModel |> move localModel.position
         ,
         pinkPlatform 30 20
         |> move (285, 125)
         |> move localModel.position
         ,
         pinkPlatform 30 20
         |> move (315, 125)
         |> move localModel.position
         ,
         pinkPlatform 30 20
         |> move (345, 125)
         |> move localModel.position
         ,
         pinkPlatform 30 20
         |> move (375, 125)
         |> move localModel.position
         ,
         gravButton (280, 145) (GlobalMsg <| CySwitch) cyan (rgb 0 170 175) localModel globalModel |> move localModel.position
         ,
         char localModel 
         |> scaleY (if globalModel.switchMagGrav then -1 else 1)
         ] |> group
       ,
       if localModel.playingMag then 
            button ("Level Select") (-65, 55) (LocalMsg <| ToSelect) (rgb 175 0 154) (rgb 255 32 234) localModel
            |> notifyTap (GlobalMsg <| SwitchOff)
          else
            button ("Level Select") (-65, 55) (LocalMsg <| ToSelect) (rgb 0 170 175) (rgb 33 250 255) localModel
            |> notifyTap (GlobalMsg <| SwitchOff)
        ,
        if localModel.pastPlatforms then
        rect 46 46
        |> filled (rgba 0 0 0 0)
        |> move (350, 100)
        |> move localModel.position
        |> notifyEnter (LocalMsg <| HoverPortal)
        |> notifyLeave (LocalMsg <| LeavePortal)
        |> notifyTap (LocalMsg <| ToSelect )
        else circle 0 |> filled (rgba 0 0 0 0)
       ]
  ]
  
icon (x, y) localModel globalModel = group
  [
  let hovered = localModel.hoveredButton == (x,y)
      clicked = List.member (x, y) globalModel.clickedIcon
  in
        square 16
        |> filled (rgba 0 0 0 0)
        |> move localModel.position
        |> move (157.5, 72.5)
        |> addOutline (solid 1) (if List.length globalModel.clickedIcon == 5 && clicked && globalModel.icon1 && globalModel.icon2 && globalModel.icon3 && globalModel.icon4 && globalModel.icon5 then green else if List.length globalModel.clickedIcon == 5 && clicked then red else if hovered || clicked then (rgb 33 250 255) else (rgba 0 0 0 0))
        |> move (x, y)
        |> notifyEnter (LocalMsg <| HoverOver (x, y))
        |> notifyLeave (LocalMsg <| LeaveHover)
        |> notifyTap (GlobalMsg <| IconClicked (x, y))
 ]
  
charSelect localModel globalModel =
  [
    html 192 128 (Html.img [HA.width 192, HA.height 128, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/charBackground.png?raw=true"] [])
    |> move (-96, 64)
    ,
    html 24 30 (Html.img [HA.width 24, HA.height 30, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/rMag0.png?raw=true"] [])
    |> move (-40, 10)
    |> scale 1.75
    ,
    html 24 30 (Html.img [HA.width 24, HA.height 30, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/lCy0.png?raw=true"] [])
    |> move (16, 10)
    |> scale 1.75
    ,
    rect 192 128
    |> filled (rgb 70 70 70)
    |> makeTransparent 0.6
    ,
    text "Choose Your Character"
    |> customFont "Irish Grover"
    |> centered
    |> bold
    |> size 15
    |> filled (rgb 150 150 165)
    |> move (0, 45)
    ,
    text "Mag"
    |> customFont "Irish Grover"
    |> centered
    |> bold
    |> size 11
    |> filled (rgb 255 32 234)
    |> move (-50, 20)
    ,
    text "Cy"
    |> customFont "Irish Grover"
    |> centered
    |> bold
    |> size 11
    |> filled (rgb 33 250 255)
    |> move (50, 20)
    ,
    button ("Back") (-65,-55) (LocalMsg <| ToTitle) (rgb 175 0 154) (rgb 255 32 234) localModel
    ,
    if globalModel.magSelected == True && globalModel.cySelected == True then
      button ("Continue") (65,-55) (LocalMsg <| ToSelect) (rgb 0 170 175) (rgb 33 250 255) localModel
    else
      circle 0
      |> filled black
    ,
    if localModel.magHovered == True && globalModel.magSelected == False then
      html 24 30 (Html.img [HA.width 24, HA.height 30, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/rMag0.png?raw=true"] [])
      |> move (-40, 10)
      |> scale 1.75
    else 
      circle 0
      |> filled black
    ,
    if localModel.cyHovered == True && globalModel.cySelected == False then
      html 24 30 (Html.img [HA.width 24, HA.height 30, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/lCy0.png?raw=true"] [])
      |> move (16, 10)
      |> scale 1.75
    else 
      circle 0
      |> filled black
    ,
    if globalModel.magSelected == True then 
      [
      circle 8
      |> filled (rgb 255 32 234)
      |> move (-20, -10)
      , 
      rect 2 7
      |> filled white
      |> rotate (degrees -35)
      |> move (-18, -9)
      , 
      rect 2 5
      |> filled white
      |> rotate (degrees 55)
      |> move (-21.75, -11.75)
      ] |> group
    else 
      rect 27 37
      |> filled black
      |> move (-49, -9)
      |> makeTransparent 0
      |> notifyEnter (LocalMsg <| HoverMag)
      |> notifyLeave (LocalMsg <| LeaveMag)
      |> notifyTap (GlobalMsg <| SelectMag)
      |> notifyTap (LocalMsg <| PlayMag)
    ,
    if globalModel.cySelected == True then 
      [
      circle 8
      |> filled (rgb 33 250 255)
      |> move (20, -10)
      , 
      rect 2 7
      |> filled white
      |> rotate (degrees -35)
      |> move (22, -9)
      , 
      rect 2 5
      |> filled white
      |> rotate (degrees 55)
      |> move (18.25, -11.75)
      ] |> group
    else 
    rect 27 37
    |> filled black
    |> move (49, -9)
    |> makeTransparent 0
    |> notifyEnter (LocalMsg <| HoverCy)
    |> notifyLeave (LocalMsg <| LeaveCy)
    |> notifyTap (GlobalMsg <| SelectCy)
    |> notifyTap (LocalMsg <| PlayCy)
    ,
    if localModel.playingMag == True then
      [html 24 30 (Html.img [HA.width 24, HA.height 30, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/rMag0.png?raw=true"] [])
      |> move (-40, 10)
      |> scale 1.75
      ,
      rect 40 80
      |> filled (rgba 0 0 0 0)
      |> move (45, 0)
      ] |> group
    else
      circle 0 
      |> filled black
    ,
    if localModel.playingCy == True then
      [html 24 30 (Html.img [HA.width 24, HA.height 30, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/lCy0.png?raw=true"] [])
      |> move (16, 10)
      |> scale 1.75
      ,
      rect 40 80
      |> filled (rgba 0 0 0 0)
      |> move (-45, 0)
      ] |> group
    else
      circle 0
      |> filled black
  ]
  
select level localModel globalModel =
  [
    arrowButton (22, -2) 1 (LocalMsg <| IncreaseLevel) (rgb 0 170 175) (rgb 33 250 255) localModel
    |> move (0, if level < 4 then 0 else -200)
    |> notifyTap (LocalMsg <| InLevel)
    , 
    arrowButton (-22, -2) -1 (LocalMsg <| DecreaseLevel) (rgb 175 0 154) (rgb 255 32 234) localModel
    |> move (0, if level == 0 then -200 else 0)
    |> notifyTap (LocalMsg <| DeLevel)
    , 
    circle 15
    |> filled (rgb 150 150 165)
    |> addOutline (solid 1) (rgb 100 100 115)
    , 
    text (Debug.toString (level + 1))
    |> customFont "Irish Grover" 
    |> centered
    |> size 10
    |> filled (rgb 100 100 115)
    |> move (0, -2.5)
    ]
    
levelSelect localModel = 
  [
    html 192 128 (Html.img [HA.width 192, HA.height 128, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/selectBackground.png?raw=true"] [])
    |> scale 2
    |> move (-192, 180)
    ,
    button ("Back") (-65,-55) (LocalMsg <| ToChar) (rgb 175 0 154) (rgb 255 32 234) localModel
    ,
    button ("Start") (65,-55) (LocalMsg <| ToGame) (rgb 0 170 175) (rgb 33 250 255) localModel
    ,
    mag localModel 
    |> move (-70, -20)
    ,
    cy localModel
    |> move (60, -20)
  ]
    
char localModel = group
  [
   case localModel.onFrame of
     (f, _) ->
       [
         if localModel.playingMag then
           if localModel.jumping || localModel.falling then html 23 28 (Html.img [HA.width 23, HA.height 28, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/jumpMag.png?raw=true"] [])
           else
             case (modBy 4 (floor f)) of
               0 -> html 23 28 (Html.img [HA.width 23, HA.height 28, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/rMag0.png?raw=true"] [])
               1 -> html 23 28 (Html.img [HA.width 23, HA.height 28, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/rMag1.png?raw=true"] [])
               2 -> html 23 28 (Html.img [HA.width 23, HA.height 28, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/rMag2.png?raw=true"] [])
               _ -> html 23 28 (Html.img [HA.width 23, HA.height 28, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/rMag3.png?raw=true"] [])
         else 
           if localModel.jumping || localModel.falling then html 21 29 (Html.img [HA.width 21, HA.height 29, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/jumpCy.png?raw=true"] [])
           else
             case (modBy 4 (floor f)) of
               0 -> html 21 29 (Html.img [HA.width 21, HA.height 29, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/rCy0.png?raw=true"] [])
               1 -> html 21 29 (Html.img [HA.width 21, HA.height 29, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/rCy1.png?raw=true"] [])
               2 -> html 21 29 (Html.img [HA.width 21, HA.height 29, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/rCy2.png?raw=true"] [])
               _ -> html 21 29 (Html.img [HA.width 21, HA.height 29, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/rCy3.png?raw=true"] [])
       ] |> group
         |> scale 2
         |> scaleX (localModel.facingDir) 
         |> move (if localModel.facingDir == -1 then 25 else -20, 13)
  ]
  
mag localModel = group
  [
   case localModel.onFrame of
     (f, _) ->
       [
       case (modBy 4 (floor f)) of
         0 -> html 23 28 (Html.img [HA.width 23, HA.height 28, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/rMag0.png?raw=true"] [])
         1 -> html 23 28 (Html.img [HA.width 23, HA.height 28, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/rMag1.png?raw=true"] [])
         2 -> html 23 28 (Html.img [HA.width 23, HA.height 28, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/rMag2.png?raw=true"] [])
         _ -> html 23 28 (Html.img [HA.width 23, HA.height 28, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/rMag3.png?raw=true"] [])
       ] |> group
         |> scale 1.5
         |> scaleX (localModel.facingDir) 
         |> move (if localModel.facingDir == -1 then 25 else -12, 13)
  ]
        
cy localModel = group
  [
   case localModel.onFrame of
     (f, _) ->
       [
       case (modBy 4 (floor f)) of
       0 -> html 21 29 (Html.img [HA.width 21, HA.height 29, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/rCy0.png?raw=true"] [])
       1 -> html 21 29 (Html.img [HA.width 21, HA.height 29, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/rCy1.png?raw=true"] [])
       2 -> html 21 29 (Html.img [HA.width 21, HA.height 29, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/rCy2.png?raw=true"] [])
       _ -> html 21 29 (Html.img [HA.width 21, HA.height 29, HA.src "https://github.com/elianamarshall/Mag-Cy/blob/main/rCy3.png?raw=true"] [])
       ] |> group
         |> scale 1.5
         |> scaleX (localModel.facingDir) 
         |> move (if localModel.facingDir == -1 then 20 else -12, 13)
  ]
  
pinkPlatform width height = group
  [
  rect width height
  |> filled (rgb 255 39 226)
  ,
  rect (width - 5) (height - 5)
  |> filled (rgb 194 37 155)
  ,
  rect (width - 7) (height - 7)
  |> filled (rgb 255 39 226)
  ,
  rect (width - 5) 1
  |> filled (rgb 174 17 135)
  |> move (0, (height - 6)/2)
  ,
  rect (width - 5) 1
  |> filled (rgb 174 17 135)
  |> move (0, -(height - 6)/2)
  ,
  rect (width) 2
  |> filled (rgb 150 12 111)
  |> move (0, -height/2)
  ]
  
bluePlatform width height = group
  [
  rect width height
  |> filled (rgb 33 244 252)
  ,
  rect (width - 5) (height - 5)
  |> filled (rgb 39 175 196)
  ,
  rect (width - 7) (height - 7)
  |> filled (rgb 33 244 252)
  ,
  rect (width - 5) 1
  |> filled (rgb 19 155 176)
  |> move (0, (height - 6)/2)
  ,
  rect (width - 5) 1
  |> filled (rgb 19 155 176)
  |> move (0, -(height - 6)/2)
  ,
  rect (width) 2
  |> filled (rgb 5 104 122)
  |> move (0, -height/2)
  ]
  
colourPlatform i width height globalModel = group 
  [
    let
      currentI = getAt i globalModel.platformColours |> Maybe.withDefault 0
      currentColour = getAt currentI cycleColours |> Maybe.withDefault black
    in
      rect width height
      |> filled currentColour
      |> notifyTap (GlobalMsg <| ClickPlatform i)
  ]
  
cPlatform c width height = group
  [
   rect width height
   |> filled c
  ]
  
arrow c = group
  [
  rect 10 20
  |> filled c
  , 
  triangle 10
  |> filled c
  |> rotate (degrees 30)
  |> move (0,-10)
  ]
  
gravButton (x, y) msg c1 c2 localModel globalModel = group
  [
  let hovered = localModel.hoveredButton == (x,y)
  in
    circle 3 
    |> filled (if hovered then c2 else c1)
    |> addOutline (solid 1) (if hovered then c1 else c2)
  ] |> move (x, y)
    |> notifyTap msg
    |> notifyEnter (LocalMsg <| HoverOver (x, y))
    |> notifyLeave (LocalMsg <| LeaveHover)
    
button txt (x, y) msg c1 c2 localModel
    = 
    let hovered = localModel.hoveredButton == (x,y)
    in [ 
        rect 51 11
          |> filled black
          |> makeTransparent 0.5
        , rect 50 10  
          |> filled (if hovered then c1 else c2)
          |> addOutline (solid 1) (if hovered then c2 else c1)
          |> move (0, if hovered then 1.5 else 0)
        , text txt 
          |> customFont "Irish Grover" 
          |> size 7
          |> bold
          |> centered 
          |> filled (if hovered then c2 else c1)
          |> move (0,-2.5) 
          |> move (0, if hovered then 1.5 else 0)
      ]
        |> group
        |> move (x, y)
        |> notifyTap msg
        |> notifyEnter (LocalMsg <| HoverOver (x, y))
        |> notifyLeave (LocalMsg <| LeaveHover)

arrowButton (x, y) sc msg c1 c2 localModel
    = 
    let hovered = localModel.hoveredButton == (x,y)
    in [
        triangle 5
        |> filled (if hovered then c1 else c2)
        |> addOutline (solid 1) (if hovered then c2 else c1)
        |> scaleX sc
        |> move (if hovered then 1.5 * sc else 0, 0)
       ]
        |> group
        |> move (x, y)
        |> notifyTap msg
        |> notifyEnter (LocalMsg <| HoverOver (x, y))
        |> notifyLeave (LocalMsg <| LeaveHover)

levelPlaceholder localModel = [
      square 2000
        |> filled black
        |> notifyEnter (LocalMsg <| InLevel)
        |> notifyEnter (LocalMsg <| ToNextLevel)]

localUpdate : LocalMsg -> LocalModel -> GlobalModel -> LocalModel
localUpdate msg localModel globalModel = 
  case msg of
    HoverOver (x,y) -> { localModel | hoveredButton = (x, y) }
    LeaveHover -> { localModel | hoveredButton = (-200, 200) }
    HoverMag -> { localModel | magHovered = if localModel.playingMag == False && localModel.playingCy == False then True else False }
    LeaveMag -> { localModel | magHovered = False }
    HoverCy -> { localModel | cyHovered = if localModel.playingMag == False && localModel.playingCy == False then True else False }
    LeaveCy -> { localModel | cyHovered = False }
    HoverPortal -> { localModel | portalHovered = True }
    LeavePortal -> { localModel | portalHovered = False }
    ToChar -> { localModel | state = Transition localModel.state CharSelect 0 }
    ToSelect -> { localModel | state = Transition localModel.state LevelSelect 0 }
    ToGame -> { localModel | state = Transition localModel.state Game 0, position = (0, 0) }
    ToTitle -> { localModel | state = Transition localModel.state Title 0 }
    ToTutorial -> { localModel | state = Transition localModel.state Tutorial 0 }
    ToPlaceholder -> { localModel | state = if globalModel.levelCounter > 1 then LevelPlaceholder else localModel.state }
    Waiting -> { localModel | wait = True } 
    InLevel -> { localModel | level = localModel.level + 1 }
    DeLevel -> { localModel | level = localModel.level - 1 }
    ToNextLevel -> { localModel | wait = False, state = Transition localModel.state Game 0, position = (0, 0) }
    IncreaseLevel -> { localModel | state = Level 1 0 }
    DecreaseLevel -> { localModel | state = Level -1 0 }
    PlayMag -> { localModel | playingMag = if localModel.playingCy == True then False else True }
    PlayCy -> { localModel | playingCy = if localModel.playingMag == True then False else True }
    Tick t (_,(x, y),_) -> 
      let
        lastTime = if localModel.time > 0 then localModel.time else t
        deltaTime = t - lastTime
        newTorchTimer = localModel.torchTimer + deltaTime
        (newImage, resetTimer) =
          if newTorchTimer < 0.3 then
            ("https://github.com/elianamarshall/Mag-Cy/blob/main/torchLight0.png?raw=true", newTorchTimer)
          else if newTorchTimer < 0.6 then
            ("https://github.com/elianamarshall/Mag-Cy/blob/main/torchLight1.png?raw=true", newTorchTimer)
          else if newTorchTimer < 0.9 then
            ("https://github.com/elianamarshall/Mag-Cy/blob/main/torchLight2.png?raw=true", newTorchTimer)
          else if newTorchTimer < 1.2 then 
            ("https://github.com/elianamarshall/Mag-Cy/blob/main/torchLight3.png?raw=true", newTorchTimer)
          else if newTorchTimer < 1.5 then
            ("https://github.com/elianamarshall/Mag-Cy/blob/main/torchLight4.png?raw=true", newTorchTimer)
          else 
            (localModel.torchImage, 0)
         
        (px, py) = localModel.position
        
        vy = localModel.velocity
          
        ay = 
            if localModel.playingCy then 
                if globalModel.switchCyGrav && localModel.level == 4 then -localModel.gravity else localModel.gravity
            else 
                if globalModel.switchMagGrav && localModel.level == 4 then -localModel.gravity else localModel.gravity
                
        shouldFall1 = (px < -80 && px > -130) || (px < -170 && px > -220) || (px < -285 && px > -340)
        shouldFall2 = (px < -50 && px > -100) || (px < -170 && px > -220) || (px < -285 && px > -340)
        shouldFall3 = (px < -50 && px > -160) || (px < -290)
        
        jump = if localModel.playingCy then
                 if globalModel.switchCyGrav && localModel.level == 4 then 
                   if onTop && y < 0 then 
                     -localModel.jumpHeight  
                   else 0
                 else if onGround && y > 0 then 
                   localModel.jumpHeight
                 else 
                   0
               else
                 if globalModel.switchMagGrav && localModel.level == 4 then 
                   if onTop && y < 0 then 
                     -localModel.jumpHeight 
                   else 0
                 else if onGround && y > 0 then
                   localModel.jumpHeight
                 else 0

        onGround = if localModel.playingCy then
                     if globalModel.switchCyGrav && localModel.level == 4 then False else py >= localModel.groundLevel
                   else 
                     if globalModel.switchMagGrav && localModel.level == 4 then False else py >= localModel.groundLevel
                     
        onTop = if localModel.playingCy then
                     if globalModel.switchCyGrav && localModel.level == 4 then py <= localModel.topLevel else False
                else
                     if globalModel.switchMagGrav && localModel.level == 4 then py <= localModel.topLevel else False
       
        newVy =  
            if ((shouldFall1 && localModel.level == 1) || (shouldFall2 && localModel.level == 3)) || (shouldFall3 && localModel.level == 4 && (if localModel.playingCy then (if globalModel.switchCyGrav then False else True) else (if globalModel.switchMagGrav then False else True))) then 
                vy + ay 
            else if onGround || onTop then 
                jump 
            else 
                vy + ay
                
        newPy = py + newVy
        newPx = (px - x)
        
        level2Door = px < -340
        level5Door = px < -300
        
        finalPx =
          if newPx < localModel.leftBound then
            localModel.leftBound
          else if newPx > localModel.rightBound then
            localModel.rightBound
          else if onTop && newPx > -30 then -30
          else if onTop && newPx < -175 && newPx > -225 then -175
          else if onTop &&  newPx < -225 && newPx > -270 then -270
          else if newPy >= 0 then 143
          else 
            newPx
        
        newArrowCounter =
          if localModel.playingMag then
            case localModel.arrowCounter of 
              0 -> if newPy >= 0 && px < -170 && px > -220 then localModel.arrowCounter + 1 else if newPy >= 0 && ((px < -50 && px > -100) || (px < -285 && px > -340)) then 0 else localModel.arrowCounter
              1 -> if newPy >= 0 && px < -285 && px > -340 then localModel.arrowCounter + 1 else if newPy >= 0 && ((px < -50 && px > -100) || (px < -170 && px > -220)) then 0 else localModel.arrowCounter
              2 -> if newPy >= 0 && px < -50 && px > -100 then localModel.arrowCounter + 1 else if newPy >= 0 && ((px < -170 && px > -220) || (px < -170 && px > -220)) then 0 else localModel.arrowCounter
              _ -> localModel.arrowCounter
          else
            case localModel.arrowCounter of 
              0 -> if newPy >= 0 && px < -285 && px > -340 then localModel.arrowCounter + 1 else if newPy >= 0 && ((px < -50 && px > -100) || (px < -170 && px > -220)) then 0 else localModel.arrowCounter
              1 -> if newPy >= 0 && px < -50 && px > -100 then localModel.arrowCounter + 1 else if newPy >= 0 && ((px < -285 && px > -340) || (px < -170 && px > -220)) then 0 else localModel.arrowCounter
              2 -> if newPy >= 0 && px < -170 && px > -220 then localModel.arrowCounter + 1 else if newPy >= 0 && ((px < -50 && px > -100) || (px < -285 && px > -340)) then 0 else localModel.arrowCounter
              _ -> localModel.arrowCounter
        
        finalPy =
          if newPy >= localModel.groundLevel && shouldFall1 == False && shouldFall2 == False && shouldFall3 == False then
            localModel.groundLevel
          else if localModel.playingCy then
            if globalModel.switchCyGrav && localModel.level == 4 then 
              if newPy <= localModel.topLevel then
                localModel.topLevel
              else newPy
            else if newPy >= 0 then 143
            else newPy
          else
            if globalModel.switchMagGrav then 
              if newPy <= localModel.topLevel then
                localModel.topLevel
              else newPy
            else if newPy >= 0 then 143
            else newPy
            
        newOnFrame =
          case localModel.state of
            Level dir k ->
              let
                (f, s) = localModel.onFrame
                newFrame = if s > 0.5 then (f + 1, 0) else (f, s + 0.05)
              in
                newFrame
            LevelSelect -> localModel.onFrame
            _ ->
              case localModel.onFrame of
                (f, s) ->
                  if px /= newPx then
                    if s > 0.5 then (f + 1, 0) else (f, s + 0.05)
                  else
                    (0, 0.5)
                    
        updatedFacingDir =
          case localModel.state of
            Level dir _ ->
              if dir > 0 then 1 else -1
            LevelSelect -> localModel.facingDir
            _ -> 
              if newPx > px then -1 else 1        
     
      in
        ({ localModel | position = if localModel.wait then (px, py) else (finalPx, finalPy), time = t, velocity = newVy, torchTimer = resetTimer, torchImage = newImage
                     , state = case localModel.state of
                         Transition from to k -> if k > 2 then to else Transition from to (k + t - localModel.time)
                         Level dir k -> if k > 0.25 then LevelSelect else Level dir (k + t - localModel.time)
                         _ -> localModel.state
                     , onFrame = newOnFrame
                     , facingDir = updatedFacingDir
                     , jumping = not onGround && not onTop
                     , falling = if ((shouldFall1 && localModel.level == 1) || (shouldFall2 && localModel.level == 3) || (shouldFall3 && localModel.level == 4 && (if localModel.playingCy then (if globalModel.switchCyGrav then False else True) else (if globalModel.switchMagGrav then False else True)))) then True else False
                     , pastHoles = level2Door
                     , pastPlatforms = level5Door
                     , arrowCounter = newArrowCounter })

globalUpdate : GlobalMsg -> GlobalModel -> GlobalModel
globalUpdate msg globalModel =
    case msg of
        NoMsg -> globalModel
        InLevelCounter -> { globalModel | levelCounter = globalModel.levelCounter + 1 }
        SelectMag -> { globalModel | magSelected = True }
        SelectCy -> { globalModel | cySelected = True }
        IconClicked coords -> { globalModel | clickedIcon = if List.length globalModel.clickedIcon == 5 then [] else coords :: globalModel.clickedIcon
                                           , icon1 = if List.length globalModel.clickedIcon == 5 then False else globalModel.icon1
                                           , icon2 = if List.length globalModel.clickedIcon == 5 then False else globalModel.icon2
                                           , icon3 = if List.length globalModel.clickedIcon == 5 then False else globalModel.icon3
                                           , icon4 = if List.length globalModel.clickedIcon == 5 then False else globalModel.icon4
                                           , icon5 = if List.length globalModel.clickedIcon == 5 then False else globalModel.icon5 }
        ClickIcon1 -> { globalModel | icon1 = True }
        ClickIcon2 -> { globalModel | icon2 = True }
        ClickIcon3 -> { globalModel | icon3 = True }
        ClickIcon4 -> { globalModel | icon4 = True }
        ClickIcon5 -> { globalModel | icon5 = True }
        ClickPlatform i -> let
                             currentI = getAt i globalModel.platformColours |> Maybe.withDefault 0
                             nextI = modBy (List.length cycleColours) (currentI + 1)
                             updatedColours = setAt i nextI globalModel.platformColours
                           in
                             { globalModel | platformColours = updatedColours }
        ClickPlatform1 ->
            let
                newPlatform1 = isPlatformColor 0 cycleColours myRed globalModel
            in
            { globalModel | platform1 = newPlatform1 }
        ClickPlatform2 ->
            let
                newPlatform2 = isPlatformColor 1 cycleColours myYellow globalModel
            in
            { globalModel | platform2 = newPlatform2 }
        ClickPlatform3 ->
            let
                newPlatform3 = isPlatformColor 2 cycleColours myGreen globalModel
            in
            { globalModel | platform3 = newPlatform3 }
        ClickPlatform4 ->
            let
                newPlatform4 = isPlatformColor 3 cycleColours myBlue globalModel
            in
            { globalModel | platform4 = newPlatform4 }
        ClickPlatform5 ->
            let
                newPlatform5 = isPlatformColor 4 cycleColours myPurple globalModel
            in
            { globalModel | platform5 = newPlatform5 }
        MagSwitch -> { globalModel | switchMagGrav = if globalModel.switchMagGrav == False then True else False }
        CySwitch -> { globalModel | switchCyGrav = if globalModel.switchCyGrav == False then True else False }
        SwitchOff -> {globalModel | switchMagGrav = False, switchCyGrav = False }
        
initLocal : LocalModel
initLocal = { hoveredButton = (-200, 200)
            , time = 0
            , level = 0
            , velocity = 0
            , gravity = 0.045
            , position = (0, 0)
            , groundLevel = -30
            , topLevel = -90
            , leftBound = -380
            , rightBound = 0
            , jumpHeight = -1.25
            , state = Title
            , magHovered = False
            , cyHovered = False
            , playingMag = False
            , playingCy = False
            , torchImage = "https://github.com/elianamarshall/Mag-Cy/blob/main/torchLight0.png?raw=true"
            , torchTimer = 0
            , onFrame = (0, 0.5)
            , facingDir = 1
            , jumping = False
            , falling = False
            , pastHoles = False
            , pastPlatforms = False
            , portalHovered = False
            , wait = False
            , arrowCounter = 0 }

initGlobal : GlobalModel
initGlobal = {levelCounter = 0
             , magSelected = False
             , cySelected = False
             , clickedIcon = []
             , icon1 = False
             , icon2 = False
             , icon3 = False
             , icon4 = False
             , icon5 = False
             , platform1 = False
             , platform2 = False
             , platform3 = False
             , platform4 = False
             , platform5 = False
             , platformColours = [1, 3, 0, 4, 2]
             , switchMagGrav = False 
             , switchCyGrav = False }

appConfig =
  simpleAppConfig
    { initLocal = initLocal
    , initGlobal = initGlobal
    , localUpdate = localUpdate
    , globalUpdate = globalUpdate
    , view = view
    , codecGlobalModel = JSON Codec.Encoders.encodeGlobalModel Codec.Decoders.decodeGlobalModel
    , codecGlobalMsg = JSON Codec.Encoders.encodeGlobalMsg Codec.Decoders.decodeGlobalMsg
    }

main : TEASyncGSVGAppWithTick () LocalModel GlobalModel LocalMsg GlobalMsg
main = 
  teaSyncAppSimpleWithTick Tick 
    appConfig

view : LocalModel -> GlobalModel -> { title: String, body : Collage (TEASync.Msg LocalMsg GlobalMsg GlobalModel) }
view localModel globalModel = 
  {
    title = "Mag & Cy"
  , body = collage 192 128 (myShapes localModel globalModel)
  }
  
getAt : Int -> List a -> Maybe a
getAt index list =
    case List.drop index list of
        [] -> Nothing
        x :: _ -> Just x
        
setAt : Int -> a -> List a -> List a
setAt index newValue list =
    let
        before = List.take index list
        after = List.drop (index + 1) list
    in
    before ++ (newValue :: after)
    
getColorForPlatform : Int -> GlobalModel -> Maybe Color
getColorForPlatform index globalModel =
    case getAt index globalModel.platformColours of
        Just colorIndex -> 
            getAt colorIndex cycleColours
        Nothing -> 
            Nothing

isPlatformColor : Int -> List Color -> Color -> GlobalModel -> Bool
isPlatformColor index colourList colorToCheck globalModel =
    case getColorForPlatform index globalModel of
        Just color -> color == colorToCheck
        Nothing -> False