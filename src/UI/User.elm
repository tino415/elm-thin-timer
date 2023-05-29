module UI.User exposing (..)

import Html.Styled as H

import User
import UI

type Authentication = Login | Registration

header : Maybe User.User -> msg -> H.Html msg
header maybeUser logoutMsg =
    case maybeUser of
        Nothing -> UI.empty
        Just user ->
            H.div []
                [ H.div [] [ H.text user.email ]
                , UI.button logoutMsg "Logout"
                ]

