module Main exposing (main)

import Browser
import Html.Styled as H

import Time
import Task
import Iso8601
import Json.Decode as D
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
    , timeZone : Time.Zone
    , flash : Maybe UI.Flash
    , processing : Maybe Processing
    , currentEntry : Maybe Entry.Entry
    , entries : List Entry.Entry
    }

type Processing = CreatingEntry | DeletingEntry | SigningIn

init : D.Value -> ( Model, Cmd Msg )
init userValue =
    let
        maybeUser = User.maybeDecode userValue
    in 
      ( { user = maybeUser
        , currentEntry = Nothing
        , entries = []
        , message = ""
        , dateTime = Nothing
        , dateTimeString = ""
        , timeZone = Time.utc
        , processing = Nothing
        , flash = Nothing
        }
      , Cmd.batch
         [ initSubscribeEntries maybeUser
         , Task.perform SetTime Time.now
         , Task.perform SetTimeZone Time.here
         ]
      )

initSubscribeEntries : Maybe User.User -> Cmd msg
initSubscribeEntries user =
    case user of
        Nothing -> Cmd.none
        Just usr -> subscribeEntries usr.id

subscribeEntries : String -> Cmd msg
subscribeEntries userId = T.subscribe (Entry.query userId)

type Msg
    -- = Login
    = Logout
    | Logedout
    | SetMessage String
    | SetDateTime String
    | SetTime Time.Posix
    | SetTimeZone Time.Zone
    | CreateEntry
    | CreateEntryResult (Maybe Entry.Entry)
    | RedoEntry Entry.Entry
    | DeleteEntry Entry.Entry
    | DeleteEntryResult (Maybe String)
    | FlashHide
    | SubmitLogin
    | SubmitRegistration
    | RegistrationResult (Maybe Registration.Registration)
    | SwitchToLogin
    | SwitchToRegistration
    | SetPassword String
    | SetUsername String
    | SetEmail String
    | SetPasswordVerify String
    | NewEntries (Maybe (List Entry.Entry))
    | Error String

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- Login ->
            -- ( model, T.login )

        Logout ->
            ( model, T.logout )

        Logedout ->
            ( { model | user = Nothing, entries = [] }, Cmd.none )

        SubmitLogin ->
            ( model
            , T.login model.username model.password
            )

        SubmitRegistration ->
            ( { model | processing = Just SigningIn }
            , T.createRecord
                  "User"
                  (Registration.encodeNew model.username model.email model.password)
            )
        RegistrationResult (Just _) ->
            ( { model
              | flash = Just (UI.Success, "You have been registered, now you can login")
              , processing = Nothing
              , authentication = UI.User.Login
              }
            , Cmd.none
            )
        RegistrationResult Nothing ->
            ( { model
              | flash = Just (UI.Error, "Unable to register you")
              , processing = Nothing
              },
              Cmd.none
            )

        SwitchToRegistration ->
            ( { model | authentication = UI.User.Registration }, Cmd.none )

        SwitchToLogin ->
            ( { model | authentication = UI.User.Login }, Cmd.none )

        SetUsername username ->
            ( { model | username = username }, Cmd.none )

        SetEmail email ->
            ( { model | email = email }, Cmd.none )

        SetPassword password ->
            ( { model | password = password }, Cmd.none )

        SetPasswordVerify passwordVerify ->
            ( { model | passwordVerify = passwordVerify }, Cmd.none )

        SetMessage message ->
            ( { model | message = message }, Cmd.none )

        SetTime dateTime ->
            ( { model
              | dateTime = Just dateTime
              , dateTimeString = HU.timeToString model.timeZone dateTime
              }
            , Cmd.none
            )

        SetTimeZone zone ->
            ( { model | timeZone = zone }
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
                  ( { model | message = "", dateTimeString = "", processing = Just CreatingEntry }
                  , T.createRecord "entries" (Entry.encodeNew model.message dateTime)
                  )
                Nothing ->
                  ( model, Cmd.none )

        RedoEntry entry ->
            case model.dateTime of
                Just dateTime ->
                  ( { model | processing = Just CreatingEntry }
                  , T.createRecord "entries" (Entry.encodeNew entry.message dateTime)
                  )
                Nothing ->
                  ( { model | flash = Just (UI.Error, "Missing datetime") }
                  , Cmd.none
                  )

        CreateEntryResult (Just _) ->
            ( { model | flash = Just (UI.Success, "Entry created"), processing = Nothing }
            , Cmd.none
            )

        CreateEntryResult Nothing ->
            ( { model | flash = Just (UI.Error, "Entry creation failed"), processing = Nothing }
            , Cmd.none
            )

        DeleteEntry entry ->
            ( { model | processing = Just DeletingEntry }
            , T.deleteRecord "entries" entry.id
            )

        DeleteEntryResult (Just _) ->
            ( { model | flash = Just (UI.Success, "Entry deleted"), processing = Nothing }
            , Cmd.none
            )

        DeleteEntryResult Nothing ->
            ( { model | flash = Just (UI.Error, "Failed to delete entry"), processing = Nothing }
            , Cmd.none
            )

        FlashHide ->
            ( { model | flash = Nothing }, Cmd.none )

        NewEntries (Just entries) ->
            let
                sortedEntries = Entry.sortByAtDESC entries
            in
              ( { model
                | currentEntry = List.head sortedEntries
                , entries = postProcessEntries sortedEntries }
              , Cmd.none
              )

        NewEntries Nothing ->
            ( model, Cmd.none )

        Error info ->
            ( { model | flash = Just (UI.Error, info) }, Cmd.none )

postProcessEntries : List Entry.Entry -> List Entry.Entry
postProcessEntries entries =
    entries
    |> List.tail
    |> Maybe.withDefault []
    |> List.take 10

view : Model -> H.Html Msg
view model =
  let
    isActionable = model.processing /= Nothing || model.user == Nothing
  in
    UI.layout
      [ UI.header
        [ UI.User.header model.user Logout
        ]
      , UI.maybeFlash model.flash FlashHide
      , UI.processing model.processing
      , UI.Entry.createForm isActionable CreateEntry
          SetMessage model.message
          SetDateTime model.dateTimeString
      , UI.Entry.current model.currentEntry model.timeZone model.dateTime
      , UI.Entry.list model.processing model.timeZone DeleteEntry RedoEntry model.entries
      ]

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ T.logedout Logedout
      , T.subscribeResult Entry.listDecoder NewEntries
      , createRecordSubscription model.processing
      , Time.every 60000 SetTime
      ]

createRecordSubscription : Maybe Processing -> Sub Msg
createRecordSubscription processing =
  case processing of
    Nothing -> Sub.none
    Just CreatingEntry -> T.createRecordResult Entry.decoder CreateEntryResult
    Just DeletingEntry -> T.deleteRecordResult DeleteEntryResult
    Just SigningIn -> T.createRecordResult Registration.decoder RegistrationResult 
        
