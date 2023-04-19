module Main exposing (main)

import Browser
import Html.Styled exposing (Html, button, div, text, ul, li, form, input, toUnstyled)
import Html.Styled.Attributes exposing (css, type_, value)
import Html.Styled.Events exposing (onClick, onInput, onSubmit)

import Time
import Json.Decode exposing (Decoder, Value, field, string, map3, list, decodeValue)
import Json.Decode.Extra exposing (datetime)
import Json.Encode as E
import Css exposing (displayFlex)

import ThinBackend as T

subscribeEntriesQuery : String -> T.Query
subscribeEntriesQuery userId =
   (T.query "entries")
        |> T.andWhereColumnEq "userId" (T.str userId)
        |> T.limit 10
        |> T.orderBy "at" T.DESC

subscribeEntries : String -> Cmd msg
subscribeEntries userId = T.subscribe (subscribeEntriesQuery userId)

entryListDecoder : Decoder (List Entry)
entryListDecoder = list entryDecoder

entryDecoder : Decoder Entry
entryDecoder =
  map3 Entry
      (field "id" string)
      (field "message" string)
      (field "at" datetime)

encodeNewEntry : String -> E.Value
encodeNewEntry message = E.object [ ("message", E.string message ) ]

main : Program (Maybe User) Model Msg
main =
    Browser.element
      { init = init
      , update = update
      , view = view >> toUnstyled
      , subscriptions = subscriptions
      }

type alias User =
    { id : String
    , email : String
    }

type alias Entry =
    { id : String
    , message : String
    , at : Time.Posix
    }

type alias Model =
    { user : Maybe User
    , message : String
    , flash : Maybe String
    , processing : Bool
    , entries : List Entry
    }

init : Maybe User -> ( Model, Cmd Msg )
init user =
    ( { user = user
      , entries = []
      , message = ""
      , processing = False
      , flash = Nothing
      }
    , initSubscribeEntries user
    )

initSubscribeEntries : Maybe User -> Cmd msg
initSubscribeEntries user =
    case user of
        Nothing -> Cmd.none
        Just usr -> subscribeEntries usr.id

type Msg
    = Login
    | Logout
    | Logedout
    | SetMessage String
    | CreateEntry
    | CreateEntryResult (Maybe Entry)
    | DeleteEntry String
    | DeleteEntryResult (Maybe String)
    | FlashHide
    | NewEntries (Maybe (List Entry))

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Login ->
            ( model, T.login )

        Logout ->
            ( model, T.logout )

        Logedout ->
            ( { model | user = Nothing }, Cmd.none )

        SetMessage message ->
            ( { model | message = message }, Cmd.none )

        CreateEntry ->
            ( { model | message = "", processing = True },
                  T.createRecord "entries" (encodeNewEntry model.message) )

        CreateEntryResult (Just _) ->
            ( { model | flash = Just "Entry created", processing = False }, Cmd.none )

        CreateEntryResult Nothing ->
            ( { model | flash = Just "Entry creation failed", processing = False }, Cmd.none )

        DeleteEntry id ->
            ( { model | processing = True }, T.deleteRecord "entries" id )

        DeleteEntryResult (Just _) ->
            ( { model | flash = Just "Entry deleted", processing = False }, Cmd.none )

        DeleteEntryResult Nothing ->
            ( { model | flash = Just "Failed to delete entry.", processing = False }, Cmd.none )

        FlashHide ->
            ( { model | flash = Nothing }, Cmd.none )

        NewEntries result ->
            case result of
                Just entries ->
                  ( { model | entries = (sortEntries entries) }, Cmd.none )
                Nothing ->
                  ( model, Cmd.none )

sortEntries : List Entry -> List Entry
sortEntries = List.sortWith compareEntriesAtDesc

compareEntriesAtDesc : Entry -> Entry -> Order
compareEntriesAtDesc e1 e2 = compare (Time.posixToMillis e2.at) (Time.posixToMillis e1.at)

view : Model -> Html Msg
view model =
    case model.user of
        Nothing ->
          layout [ button [ onClick Login ] [ text "Login" ] ]
        Just user ->
          layout
            [ div [] [text user.email]
            , viewFlash model.flash
            , viewProcessing model.processing
            , viewCreateForm model
            , button [ onClick Logout ] [ text "Logout" ]
            , ul [] (List.map (viewEntry model.processing) model.entries)
            ]

layout : List (Html Msg) -> Html Msg
layout body =
    div [
     css
     [ Css.displayFlex
     , Css.flexDirection Css.column
     , Css.maxWidth (Css.px 900)
     , Css.margin2 (Css.px 0) Css.auto
     ]] body

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

viewMonth : Time.Month -> String
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

viewZeroPaddet : Int -> String
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
        [ T.logedout Logedout
        , T.subscribeResult entryListDecoder NewEntries
        , T.createRecordResult entryDecoder CreateEntryResult
        , T.deleteRecordResult DeleteEntryResult
        ]
