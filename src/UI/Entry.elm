module UI.Entry exposing (..)

import Html.Styled as H
import Html.Styled.Attributes as A
import Html.Styled.Events as E
import Css

import UI
import Entry
import UI.DateTime

list : Bool -> (String -> msg) -> List Entry.Entry -> H.Html msg
list isProcessing deleteMsg entries =
    H.ul []
        (List.map (listItem isProcessing deleteMsg) entries)

listItem : Bool -> (String -> msg) -> Entry.Entry -> H.Html msg
listItem isProcessing deleteMsg entry =
    H.li []
        [ H.div [] [H.text entry.message]
        , H.div [] [H.text (UI.DateTime.dateTime entry.at)]
        , if isProcessing
            then UI.empty
            else UI.button (deleteMsg entry.id) "-"
        ]

createForm : Bool -> msg -> (String -> msg) -> String -> H.Html msg
createForm isHidden submitMsg updateMsg value =
    if isHidden
        then UI.empty
        else UI.form submitMsg [ UI.textInput updateMsg value ]


