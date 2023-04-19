module UI exposing (..)

import Html.Styled as H
import Html.Styled.Attributes as A
import Html.Styled.Events as E
import Css

type alias Flash = (FlashType, String)

type FlashType = Success | Error

colors : { info : Css.Color, success : Css.Color, danger : Css.Color }
colors =
  { info = Css.rgb 61 165 244
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
textInput event value =
    H.input
      [ A.type_ "text"
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

dateTimeInput : (String -> msg) -> String -> H.Html msg
dateTimeInput event value =
    H.input
      [ A.type_ "datetime-local"
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
