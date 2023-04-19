port module ThinBackend exposing (..)

import Json.Encode as E
import Json.Decode as D

type Direction = ASC | DESC

type Value = IntValue Int | StringValue String

type alias Equal = (String, Value)

type Condition =
    ColumnEq String Value
    | And Condition Condition

type alias QueryOrder = (String, Direction)

type alias Query =
    { from : String
    , limit : Maybe Int
    , order : List QueryOrder
    , andWhere : List Equal
    }

query : String -> Query
query from =
    { from = from
    , limit = Nothing
    , order = []
    , andWhere = []
    }

str : String -> Value
str value = StringValue value

int : Int -> Value
int value = IntValue value

andWhereColumnEq : String -> Value -> Query -> Query
andWhereColumnEq column value qr =
    { qr | andWhere = List.append qr.andWhere [(column, value)] }

limit : Int -> Query -> Query
limit num qr = { qr | limit = Just num }

orderBy : String -> Direction -> Query -> Query
orderBy column direction  qr = { qr | order = List.append qr.order [(column, direction)] }

list : Query -> Cmd msg
list qr = listPort (encodeQuery qr)

listResult : D.Decoder a -> (Maybe a -> msg) -> Sub msg
listResult decoder callback = listResultPort (maybeDecode decoder callback)

maybeDecode : D.Decoder a -> (Maybe a -> msg) -> D.Value -> msg
maybeDecode decoder callback value =
    case D.decodeValue decoder value of
        Ok decoded -> callback (Just decoded)
        Err _ -> callback Nothing

port listPort : D.Value -> Cmd msg
port listResultPort : (D.Value -> msg) -> Sub msg

subscribe : Query -> Cmd msg
subscribe qr = subscribePort (encodeQuery qr)

subscribeResult : D.Decoder a -> (Maybe a -> msg) -> Sub msg
subscribeResult decoder callback = subscribeResultPort (maybeDecode decoder callback)

port subscribePort : D.Value -> Cmd msg
port subscribeResultPort : (D.Value -> msg) -> Sub msg

createRecord : String -> E.Value -> Cmd msg
createRecord collection value = createRecordPort (encodeCreate collection value)

createRecordResult : D.Decoder a -> (Maybe a -> msg) -> Sub msg
createRecordResult decoder callback = createRecordResultPort (maybeDecode decoder callback)

port createRecordPort : D.Value -> Cmd msg
port createRecordResultPort : (D.Value -> msg) -> Sub msg

deleteRecord : String -> String -> Cmd msg
deleteRecord collection id = deleteRecordPort (encodeDelete collection id)

deleteRecordResult : (Maybe String -> msg) -> Sub msg
deleteRecordResult callback = deleteRecordResultPort (decodeDelete callback)

port deleteRecordPort : D.Value -> Cmd msg
port deleteRecordResultPort : (D.Value -> msg) -> Sub msg

login : Cmd msg
login = loginPort E.null

port loginPort : E.Value -> Cmd msg

logout : Cmd msg
logout = logoutPort E.null

port logoutPort : E.Value -> Cmd msg

logedout : msg -> Sub msg
logedout callback = logedoutPort (\_ -> callback)

port logedoutPort : (D.Value -> msg) -> Sub msg

decodeDelete : (Maybe String -> msg) -> D.Value -> msg
decodeDelete callback value =
    case D.decodeValue D.string value of
        Ok id -> callback (Just id)
        Err _ -> callback Nothing

encodeQuery : Query -> E.Value
encodeQuery qr =
    E.object
        [ ( "from", E.string qr.from )
        , ( "limit", encodeLimit qr.limit )
        , ( "order", (E.list encodeOrder qr.order) )
        , ( "andWhere", (E.list encodeWhere qr.andWhere ) )
        ]

encodeLimit : Maybe Int -> E.Value 
encodeLimit num =
    case num of
        Nothing -> E.null
        Just nm -> E.int nm

encodeOrder : (String, Direction) -> E.Value
encodeOrder (column, direction) =
    E.object
        [ ( "column", E.string column )
        , ( "direction", encodeOrderDirection direction )
        ]

encodeOrderDirection : Direction -> E.Value
encodeOrderDirection direction =
    case direction of
        DESC -> E.string "DESC"
        ASC -> E.string "ASC"

encodeWhere : Equal -> E.Value
encodeWhere (column, value) =
    E.object
        [ ( "column", E.string column )
        , ( "value", encodeValue value )
        ]

encodeValue : Value -> E.Value
encodeValue vl =
    case vl of
        IntValue val -> E.int val
        StringValue val -> E.string val

encodeCreate : String -> E.Value -> E.Value
encodeCreate collection record =
    E.object
        [ ( "collection", E.string collection )
        , ( "record", record )
        ]

encodeDelete : String -> String -> E.Value
encodeDelete collection id =
    E.object
        [ ( "collection", E.string collection )
        , ( "id", E.string id )
        ]
