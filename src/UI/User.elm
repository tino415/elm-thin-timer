module UI.User exposing (..)

import Html.Styled as H

import User
import UI

type Authentication = Login | Registration

header : Maybe User.User -> msg -> msg -> H.Html msg
header maybeUser loginMsg logoutMsg =
    case maybeUser of
        Nothing -> UI.button loginMsg "Login"
        Just user ->
            H.div []
                [ H.div [] [ H.text user.email ]
                , UI.button logoutMsg "Logout"
                ]

authenticationForm :
    Authentication
        -> msg -> msg -> msg -> msg
        -> (String -> msg) -> String
        -> (String -> msg) -> String
        -> (String -> msg) -> String
        -> H.Html msg
authenticationForm
    authentication
    registrationSubmitMsg loginSubmitMsg
    switchToLoginMsg switchToRegistrationMsg
    emailMsg email
    passwordMsg password
    passwordVerifyMsg passwordVerify =
    case authentication of
        Login ->
            loginForm
                loginSubmitMsg
                switchToRegistrationMsg
                emailMsg email
                passwordMsg password
        Registration ->
            registrationForm
                registrationSubmitMsg
                switchToLoginMsg
                emailMsg email
                passwordMsg password
                passwordVerifyMsg passwordVerify

registrationForm : msg -> msg
                 -> (String -> msg) -> String
                 -> (String -> msg) -> String
                 -> (String -> msg) -> String
                 -> H.Html msg
registrationForm
    submitMsg
    switchToLoginMsg
    emailMsg email
    passwordMsg password
    passwordVerifyMsg passwordVerify =
  H.div []
    [ H.div [] [H.text "Registration"]
    , UI.button switchToLoginMsg "Login instead"
    , UI.form submitMsg
        [ UI.field "Email" (UI.emailInput emailMsg email)
        , UI.field "Password" (UI.passwordInput passwordMsg password)
        , UI.field "Password Repeat" (UI.passwordInput passwordVerifyMsg passwordVerify)
        , UI.submitButton "Sign Up"
        ]
    ]

loginForm : msg -> msg
          -> (String -> msg) -> String
          -> (String -> msg) -> String
          -> H.Html msg
loginForm submitMsg switchToRegistrationMsg emailMsg email passwordMsg password =
    H.div []
        [ H.div [] [H.text "Login"]
        , UI.button switchToRegistrationMsg "Sign Up instead"
        , UI.form submitMsg
              [ UI.field "Email" (UI.emailInput emailMsg email)
              , UI.field "Password" (UI.passwordInput passwordMsg password)
              , UI.submitButton "Login"
              ]
        ]

