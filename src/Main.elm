module Main exposing (main)

import Browser
import Html.Styled as H

import Time
import Json.Decode as D
import Json.Encode as E

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
        , processing = False
        , flash = Nothing
        }
      , initSubscribeEntries maybeUser
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
    | CreateEntry
    | CreateEntryResult (Maybe Entry.Entry)
    | DeleteEntry String
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

        CreateEntry ->
            ( { model | message = "", processing = True }
            , T.createRecord "entries" (Entry.encodeNew model.message)
            )

        CreateEntryResult (Just _) ->
            ( { model | flash = Just (UI.Success, "Entry created"), processing = False }
            , Cmd.none
            )

        CreateEntryResult Nothing ->
            ( { model | flash = Just (UI.Error, "Entry creation failed"), processing = False }
            , Cmd.none
            )

        DeleteEntry id ->
            ( { model | processing = True }
            , T.deleteRecord "entries" id
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
            ( { model | entries = (Entry.sortByAtDESC entries) }, Cmd.none )

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
      , UI.Entry.createForm isActionable CreateEntry SetMessage model.message
      , UI.Entry.list model.processing DeleteEntry model.entries
      ]

subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ T.logedout Logedout
        , T.subscribeResult Entry.listDecoder NewEntries
        , T.createRecordResult Entry.decoder CreateEntryResult
        , T.deleteRecordResult DeleteEntryResult
        ]
