port module Main exposing (..)

import Browser
import Html exposing (Html, button, div, text, ul, li)
import Html.Events exposing (onClick)

import Time
import Json.Decode exposing (Decoder, Value, field, string, map2, list, decodeValue)
import Json.Decode.Extra exposing (datetime)


-- Ports

port login : String -> Cmd msg
port logout : String -> Cmd msg
port subscribeEntries : String -> Cmd msg
port logedout : (String -> msg) -> Sub msg
port retrieveEntries : (Value -> msg) -> Sub msg

entryListDecoder : Decoder (List Entry)
entryListDecoder =
    list
      (map2 Entry
          (field "message" string)
          (field "at" datetime))
          

main : Program (Maybe User) Model Msg
main =
    Browser.element
      { init = init
      , update = update
      , view = view
      , subscriptions = subscriptions
      }

type alias User =
    { email : String
    }

type alias Entry =
    { message : String
    , at : Time.Posix
    }

type alias Model =
    { counter : Int
    , user : Maybe User
    , entries : List Entry
    }

init : Maybe User -> ( Model, Cmd Msg )
init user =
    ( { counter = 0, user = user, entries = [] }, initSubscribeEntries user )

initSubscribeEntries user =
    case user of
        Nothing -> Cmd.none
        Just _ -> subscribeEntries ""

type Msg
    = Increment
    | Decrement
    | Login
    | Logout
    | Logedout String
    | NewEntries (Result Json.Decode.Error (List Entry))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( { model | counter = model.counter + 1 }, Cmd.none )

        Decrement ->
            ( { model | counter = model.counter - 1 }, Cmd.none )

        Login ->
            ( model, login "Test" )

        Logout ->
            ( model, logout "Test" )

        Logedout _ ->
            ( { model | user = Nothing }, Cmd.none )

        NewEntries result ->
            case result of
                Ok entries ->
                  ( { model | entries = entries }, Cmd.none )
                _ ->
                  ( model, Cmd.none )


view : Model -> Html Msg
view model =
    case model.user of
        Nothing ->
          div []
            [ button [ onClick Login ] [ text "Login" ] ]
        Just user ->
          div []
            [ div [] [text user.email]
            , button [ onClick Decrement ] [ text "-" ]
            , div [] [ text (String.fromInt model.counter) ]
            , button [ onClick Increment ] [ text "+" ]
            , button [ onClick Logout ] [ text "Logout" ]
            , ul [] (List.map viewEntry model.entries)
            ]

viewEntry : Entry -> Html Msg
viewEntry entry =
    li []
        [div [] [text entry.message]
        ,div [] [text (viewDateTime entry.at)]
        ]

viewDateTime : Time.Posix -> String
viewDateTime time =
    String.fromInt (Time.toYear Time.utc time) ++ "-" ++
    String.fromInt (viewMonth (Time.toMonth Time.utc time)) ++ "-" ++
    String.fromInt (Time.toDay Time.utc time) ++ " " ++
    String.fromInt (Time.toHour Time.utc time) ++ ":" ++
    String.fromInt (Time.toMinute Time.utc time) ++ ":" ++
    String.fromInt (Time.toSecond Time.utc time)

viewMonth month =
    case month of
      Time.Jan -> 1
      Time.Feb -> 2
      Time.Mar -> 3
      Time.Apr -> 4
      Time.May -> 5
      Time.Jun -> 6
      Time.Jul -> 7
      Time.Aug -> 8
      Time.Sep -> 9
      Time.Oct -> 10
      Time.Nov -> 11
      Time.Dec -> 12

subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ logedout Logedout
        , retrieveEntries (decodeValue entryListDecoder >> NewEntries)
        ]
