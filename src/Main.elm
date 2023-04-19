module Main exposing (main)

import Browser
import Html.Styled as H

import Time
import Task
import Iso8601
import Json.Decode as D
import Json.Encode as E
import Html.Utils as HU

import ThinBackend as T
import UI
import UI.Entry
import UI.User
import Entry
import User

main : Program D.Value Model Msg
main =
    Browser.element
      { init = init
      , update = update
      , view = view >> H.toUnstyled
      , subscriptions = subscriptions
      }

type alias Model =
    { user : Maybe User.User
    , message : String
    , dateTime : Maybe Time.Posix
    , dateTimeString : String
    , flash : Maybe UI.Flash
    , processing : Bool
    , entries : List Entry.Entry
    }

init : D.Value -> ( Model, Cmd Msg )
init userValue =
    let
        maybeUser = User.maybeDecode userValue
    in 
      ( { user = maybeUser
        , entries = []
        , message = ""
        , dateTime = Nothing
        , dateTimeString = ""
        , processing = False
        , flash = Nothing
        }
      , Cmd.batch [initSubscribeEntries maybeUser, Task.perform SetTime Time.now]
      )

initSubscribeEntries : Maybe User.User -> Cmd msg
initSubscribeEntries user =
    case user of
        Nothing -> Cmd.none
        Just usr -> subscribeEntries usr.id

subscribeEntries : String -> Cmd msg
subscribeEntries userId = T.subscribe (Entry.query userId)

type Msg
    = Login
    | Logout
    | Logedout
    | SetMessage String
    | SetDateTime String
    | SetTime Time.Posix
    | CreateEntry
    | CreateEntryResult (Maybe Entry.Entry)
    | RedoEntry Entry.Entry
    | DeleteEntry Entry.Entry
    | DeleteEntryResult (Maybe String)
    | FlashHide
    | NewEntries (Maybe (List Entry.Entry))

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Login ->
            ( model, T.login )

        Logout ->
            ( model, T.logout )

        Logedout ->
            ( { model | user = Nothing, entries = [] }, Cmd.none )

        SetMessage message ->
            ( { model | message = message }, Cmd.none )

        SetTime dateTime ->
            ( { model | dateTime = Just dateTime, dateTimeString = HU.timeToString dateTime }
            , Cmd.none
            )

        SetDateTime dateTimeString ->
            case Iso8601.toTime dateTimeString of
                Ok dateTime ->
                  ( { model | dateTime = Just dateTime, dateTimeString = dateTimeString }
                  , Cmd.none
                  )
                Err _ ->
                  ( { model | dateTimeString = "" }, Cmd.none )

        CreateEntry ->
            case model.dateTime of
                Just dateTime ->
                  ( { model | message = "", dateTimeString = "", processing = True }
                  , T.createRecord "entries" (Entry.encodeNew model.message dateTime)
                  )
                Nothing ->
                  ( model, Cmd.none )

        RedoEntry entry ->
            case model.dateTime of
                Just dateTime ->
                  ( { model | processing = True }
                  , T.createRecord "entries" (Entry.encodeNew entry.message dateTime)
                  )
                Nothing ->
                  ( { model | flash = Just (UI.Error, "Missing datetime") }
                  , Cmd.none
                  )

        CreateEntryResult (Just _) ->
            ( { model | flash = Just (UI.Success, "Entry created"), processing = False }
            , Cmd.none
            )

        CreateEntryResult Nothing ->
            ( { model | flash = Just (UI.Error, "Entry creation failed"), processing = False }
            , Cmd.none
            )

        DeleteEntry entry ->
            ( { model | processing = True }
            , T.deleteRecord "entries" entry.id
            )

        DeleteEntryResult (Just _) ->
            ( { model | flash = Just (UI.Success, "Entry deleted"), processing = False }
            , Cmd.none
            )

        DeleteEntryResult Nothing ->
            ( { model | flash = Just (UI.Error, "Failed to delete entry"), processing = False }
            , Cmd.none
            )

        FlashHide ->
            ( { model | flash = Nothing }, Cmd.none )

        NewEntries (Just entries) ->
            ( { model | entries = (List.take 10 (Entry.sortByAtDESC entries)) }
            , Cmd.none
            )

        NewEntries Nothing ->
            ( model, Cmd.none )

view : Model -> H.Html Msg
view model =
  let
    isActionable = model.processing || model.user == Nothing
  in
    UI.layout
      [ UI.header
        [ UI.User.header model.user Login Logout
        ]
      , UI.maybeFlash model.flash FlashHide
      , UI.processing model.processing
      , UI.Entry.createForm isActionable CreateEntry
          SetMessage model.message
          SetDateTime model.dateTimeString
      , UI.Entry.list model.processing DeleteEntry RedoEntry model.entries
      ]

viewDefaultDatetime maybeDateTime =
    case maybeDateTime of
        Nothing -> ""
        Just dateTime -> Iso8601.fromTime dateTime

subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ T.logedout Logedout
        , T.subscribeResult Entry.listDecoder NewEntries
        , T.createRecordResult Entry.decoder CreateEntryResult
        , T.deleteRecordResult DeleteEntryResult
        ]
