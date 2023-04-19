module UI.Entry exposing (..)

import Time

import Html.Styled as H
import Html.Styled.Attributes as A
import Html.Styled.Events as E
import Css

import UI
import Entry
import UI.DateTime

current : Maybe Entry.Entry -> Maybe Time.Posix -> H.Html msg
current maybeEntry maybeNow =
    case (maybeEntry, maybeNow) of
        (Just entry, Just now) ->
          H.div
            []
            [ H.text entry.message
            , let
                  diff = UI.DateTime.diff now entry.at
              in
                  H.div []
                      [ H.div [] [H.text ("Started at: " ++ (UI.DateTime.dateTime entry.at))]
                      , H.div [] [H.text ("Running for " ++ (UI.DateTime.printDiff diff))]
                      ]
            ]
        _ -> UI.empty

list : Bool -> (Entry.Entry -> msg) -> (Entry.Entry -> msg) -> List Entry.Entry -> H.Html msg
list isProcessing deleteMsg redoMsg entries =
    H.ul []
        (List.map (listItem isProcessing deleteMsg redoMsg) entries)

listItem : Bool -> (Entry.Entry -> msg) -> (Entry.Entry -> msg) -> Entry.Entry -> H.Html msg
listItem isProcessing deleteMsg redoMsg entry =
    H.li
        [
          A.css
            [ Css.listStyle Css.none
            , Css.displayFlex
            , Css.padding2 (Css.em 0.5) (Css.em 1)
            ]
        ]
        [ H.div
            [ A.css
               [ Css.flexGrow (Css.num 1)
               , Css.padding2 (Css.em 0.5) (Css.em 1)
               ]
            ]
            [ H.text entry.message ]
        , H.div
            [ A.css
               [ Css.padding2 (Css.em 0.5) (Css.em 1)
               ]
            ]
            [ H.text (UI.DateTime.dateTime entry.at) ]
        , if isProcessing
            then UI.empty
            else
              H.div
                []
                [ UI.button (redoMsg entry) ">"
                , UI.button (deleteMsg entry) "-"
                ]
        ]

createForm : Bool -> msg -> (String -> msg) -> String -> (String -> msg) -> String -> H.Html msg
createForm isHidden submitMsg updateMsg value updateDatetimeMsg dateTimeValue =
    if isHidden
        then UI.empty
        else
            UI.form
                submitMsg
                [ UI.textInput updateMsg value
                , UI.dateTimeInput updateDatetimeMsg dateTimeValue
                ]


