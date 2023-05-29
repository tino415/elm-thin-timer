port module Parse exposing (..)

createRecord : String -> E.Value -> Cmd msg
createRecord collection value = createRecordPort (encodeCreate collection value)

createRecordResult : D.Decoder a -> (Maybe a -> msg) -> Sub msg
createRecordResult decoder callback = createRecordResultPort (maybeDecodeCall decoder callback)

port createRecordPort : D.Value -> Cmd msg
port createRecordResultPort : (D.Value -> msg) -> Sub msg


