module UI exposing (..)

import Html.Styled as H
import Html.Styled.Attributes as A
import Html.Styled.Events as E
import Css

type alias Flash = (FlashType, String)

type FlashType = Success | Error

colors : { info : Css.Color, infoHover : Css.Color, success : Css.Color, danger : Css.Color }
colors =
  { info = Css.rgb 61 165 244
  , infoHover = Css.rgb 78 181 219
  , success = Css.rgb 44 228 104
  , danger = Css.rgb 229 88 94
  }

empty : H.Html msg
empty = H.div [][]

button : msg -> String -> H.Html msg
button msg content =
    H.button
        [ E.onClick msg
        , A.css
            [ Css.backgroundColor (colors.info)
            , Css.borderWidth (Css.px 0)
            , Css.padding2 (Css.em 0.5) (Css.em 1)
            , Css.cursor Css.pointer
            , Css.margin (Css.em 0.2)
            , Css.hover
                [ Css.backgroundColor colors.infoHover
                ]
            ]
        ]
        [ H.text content ]

submitButton : String -> H.Html msg
submitButton content =
    H.button
        [ A.css
            [ Css.backgroundColor (colors.info)
            , Css.borderWidth (Css.px 0)
            , Css.padding2 (Css.em 0.5) (Css.em 1)
            , Css.cursor Css.pointer
            , Css.margin (Css.em 0.2)
            , Css.hover
                [ Css.backgroundColor colors.infoHover
                ]
            ]
        ]
        [ H.text content ]

form : msg -> (List (H.Html msg)) -> H.Html msg
form msg body =
    H.form
      [ E.onSubmit msg
      , A.css
         [ Css.display Css.block
         , Css.width (Css.pct 100)
         , Css.boxSizing Css.borderBox
         , Css.padding (Css.em 1)
         ]
      ]
      body

textInput : (String -> msg) -> String -> H.Html msg
textInput = input "text"

emailInput : (String -> msg) -> String -> H.Html msg
emailInput = input "email"

passwordInput : (String -> msg) -> String -> H.Html msg
passwordInput = input "password"

dateTimeInput : (String -> msg) -> String -> H.Html msg
dateTimeInput = input "datetime-local"


field : String -> H.Html msg -> H.Html msg
field name input_ =
    H.div []
        [ H.label [A.css [Css.display Css.block]] [H.text name]
        , input_
        ]

input : String -> (String -> msg) -> String -> H.Html msg
input type_ event value =
    H.input
      [ A.type_ type_
      , A.value value
      , E.onInput event
      , A.css
         [ Css.borderWidth (Css.px 1)
         , Css.padding2 (Css.em 0.5) (Css.em 1)
         , Css.borderColor colors.info
         , Css.borderStyle Css.solid
         ]
      ]
      []

layout : List (H.Html msg) -> H.Html msg
layout body =
    H.div [
     A.css
     [ Css.displayFlex
     , Css.flexDirection Css.column
     , Css.maxWidth (Css.px 900)
     , Css.margin2 (Css.px 0) Css.auto
     ]] body

header : List (H.Html msg) -> H.Html msg
header body =
    H.div
      [ A.css
          [ Css.displayFlex
          ]
      ] body

maybeFlash : Maybe Flash -> msg -> H.Html msg
maybeFlash maybe msg =
    case maybe of
        Nothing -> empty
        Just flsh -> flash flsh msg

flash : Flash -> msg -> H.Html msg
flash (tp, message) msg =
  H.div
    [ A.css
       [ Css.backgroundColor colors.success
       , Css.padding2 (Css.em 0.5) (Css.em 1)
       , Css.margin (Css.em 0.5)
       , Css.displayFlex
       , Css.justifyContent Css.spaceBetween
       ]
    ]
    [ H.text message
    , H.a
        [ E.onClick msg
        , A.css
           [ Css.cursor Css.pointer
           ]
        ]
        [ H.text "x" ]
    ]

flashColor : FlashType -> Css.Color
flashColor tp =
    case tp of
        Success -> colors.success
        Error -> colors.danger

processing : Bool -> H.Html msg
processing isProcessing =
    if isProcessing
        then H.div [][ H.text "Processing" ]
        else empty
