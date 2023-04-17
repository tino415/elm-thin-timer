port module Main exposing (..)

import Browser
import Html
import Html.Styled exposing (Html, button, div, text, ul, li, form, input, toUnstyled)
import Html.Styled.Attributes exposing (css, type_, value)
import Html.Styled.Events exposing (onClick, onInput, onSubmit)

import Time
import Json.Decode exposing (Decoder, Value, field, string, map3, list, decodeValue)
import Json.Decode.Extra exposing (datetime)
import Css exposing (displayFlex)


-- Ports

port login : String -> Cmd msg
port logout : String -> Cmd msg
port createEntry : String -> Cmd msg
port subscribeEntries : String -> Cmd msg
port deleteEntry : String -> Cmd msg

port logedout : (String -> msg) -> Sub msg
port retrieveEntries : (Value -> msg) -> Sub msg
port createEntrySuccess : (Value -> msg) -> Sub msg
port createEntryFail : (Value -> msg) -> Sub msg
port deleteEntrySuccess : (Value -> msg) -> Sub msg
port deleteEntryFail : (Value -> msg) -> Sub msg

entryListDecoder : Decoder (List Entry)
entryListDecoder =
    list
      (map3 Entry
          (field "id" string)
          (field "message" string)
          (field "at" datetime))


main : Program (Maybe User) Model Msg
main =
    Browser.element
      { init = init
      , update = update
      , view = view >> toUnstyled
      , subscriptions = subscriptions
      }

type alias User =
    { email : String
    }

type alias Entry =
    { id : String
    , message : String
    , at : Time.Posix
    }

type alias Model =
    { counter : Int
    , user : Maybe User
    , message : String
    , flash : Maybe String
    , processing : Bool
    , entries : List Entry
    }

init : Maybe User -> ( Model, Cmd Msg )
init user =
    ( { counter = 0
      , user = user
      , entries = []
      , message = ""
      , processing = False
      , flash = Nothing
      }
    , initSubscribeEntries user
    )

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
    | SetMessage String
    | CreateEntry
    | CreateEntrySuccess Value
    | CreateEntryFail Value
    | DeleteEntry String
    | DeleteEntrySuccess Value
    | DeleteEntryFail Value
    | FlashHide
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

        SetMessage message ->
            ( { model | message = message }, Cmd.none )

        CreateEntry ->
            ( { model | message = "", processing = True }, createEntry model.message )

        CreateEntrySuccess _ ->
            ( { model | flash = Just "Entry created", processing = False }, Cmd.none )

        CreateEntryFail _ ->
            ( { model | flash = Just "Entry creation failed", processing = False }, Cmd.none )

        DeleteEntry id ->
            ( { model | processing = True }, deleteEntry id )

        DeleteEntrySuccess _ ->
            ( { model | flash = Just "Entry deleted", processing = False }, Cmd.none )

        DeleteEntryFail _ ->
            ( { model | flash = Just "Failed to delete entry.", processing = False }, Cmd.none )

        FlashHide ->
            ( { model | flash = Nothing }, Cmd.none )

        NewEntries result ->
            case result of
                Ok entries ->
                  ( { model | entries = (sortEntries entries) }, Cmd.none )
                _ ->
                  ( model, Cmd.none )

sortEntries : List Entry -> List Entry
sortEntries = List.sortWith compareEntriesAtDesc

compareEntriesAtDesc : Entry -> Entry -> Order
compareEntriesAtDesc e1 e2 = compare (Time.posixToMillis e2.at) (Time.posixToMillis e1.at)

view : Model -> Html Msg
view model =
    case model.user of
        Nothing ->
          div
            [css [displayFlex]]
            [ button [ onClick Login ] [ text "Login" ] ]
        Just user ->
          div [css [displayFlex]]
            [ div [] [text user.email]
            , viewFlash model.flash
            , viewProcessing model.processing
            , viewCreateForm model
            , button [ onClick Decrement ] [ text "-" ]
            , div [] [ text (String.fromInt model.counter) ]
            , button [ onClick Increment ] [ text "+" ]
            , button [ onClick Logout ] [ text "Logout" ]
            , ul [] (List.map (viewEntry model.processing) model.entries)
            ]

viewProcessing : Bool -> Html Msg
viewProcessing processing =
    if processing
        then div [][text "Processing"]
        else div [][]

viewCreateForm : Model -> Html Msg
viewCreateForm model =
    if model.processing
        then div [][]
        else
            form [onSubmit CreateEntry]
                [ input [type_ "text", value model.message, onInput SetMessage][]
                ]

viewFlash : Maybe String -> Html Msg
viewFlash flash =
    case flash of
        Nothing -> div [][]
        Just message ->
            div []
                [ text message
                , button [onClick FlashHide][text "Hide"]
                ]

viewEntry : Bool -> Entry -> Html Msg
viewEntry processing entry =
    li []
        [ div [] [text entry.message]
        , div [] [text (viewDateTime entry.at)]
        , if processing
            then div [][]
            else button [onClick (DeleteEntry entry.id)][text "-"]
        ]

viewDateTime : Time.Posix -> String
viewDateTime time =
    viewZeroPaddet(Time.toYear Time.utc time) ++ "-" ++
    viewMonth (Time.toMonth Time.utc time) ++ "-" ++
    viewZeroPaddet (Time.toDay Time.utc time) ++ " " ++
    viewZeroPaddet (Time.toHour Time.utc time) ++ ":" ++
    viewZeroPaddet (Time.toMinute Time.utc time) ++ ":" ++
    viewZeroPaddet (Time.toSecond Time.utc time)

viewMonth month =
    case month of
      Time.Jan -> "01"
      Time.Feb -> "02"
      Time.Mar -> "03"
      Time.Apr -> "04"
      Time.May -> "05"
      Time.Jun -> "06"
      Time.Jul -> "07"
      Time.Aug -> "08"
      Time.Sep -> "09"
      Time.Oct -> "10"
      Time.Nov -> "11"
      Time.Dec -> "12"

viewZeroPaddet number =
  let
      strnum = String.fromInt number
  in
      if number > 9
          then strnum
          else "0" ++ strnum

subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ logedout Logedout
        , retrieveEntries (decodeValue entryListDecoder >> NewEntries)
        , createEntrySuccess CreateEntrySuccess
        , createEntryFail CreateEntryFail
        , deleteEntrySuccess DeleteEntrySuccess
        , deleteEntryFail DeleteEntryFail
        ]
