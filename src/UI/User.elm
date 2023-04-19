module UI.User exposing (..)

import Html.Styled as H

import User
import UI

header : Maybe User.User -> msg -> msg -> H.Html msg
header maybeUser loginMsg logoutMsg =
    case maybeUser of
        Nothing -> UI.button loginMsg "Login"
        Just user ->
            H.div []
                [ H.div [] [ H.text user.email ]
                , UI.button logoutMsg "Logout"
                ]

