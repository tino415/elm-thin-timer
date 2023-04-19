module Entry exposing (..)

import Time
import Json.Decode as D
import Json.Decode.Extra as DE
import Json.Encode as E

import ThinBackend as T

type alias Entry =
    { id : String
    , message : String
    , at : Time.Posix
    }

decoder : D.Decoder Entry
decoder =
  D.map3 Entry
      (D.field "id" D.string)
      (D.field "message" D.string)
      (D.field "at" DE.datetime)

listDecoder : D.Decoder (List Entry)
listDecoder = D.list decoder

encodeNew : String -> E.Value
encodeNew message = E.object [ ("message", E.string message ) ]

sortByAtDESC : List Entry -> List Entry
sortByAtDESC = List.sortWith compareByAtDESC

compareByAtDESC : Entry -> Entry -> Order
compareByAtDESC e1 e2 = compare (Time.posixToMillis e2.at) (Time.posixToMillis e1.at)

query : String -> T.Query
query userId =
   (T.query "entries")
        |> T.andWhereColumnEq "userId" (T.str userId)
        |> T.limit 10
        |> T.orderBy "at" T.DESC

