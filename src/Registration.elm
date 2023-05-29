module Registration exposing (..)

import Json.Decode as D
import Json.Utils as JU
import Json.Encode as E

type alias Registration =
    { username : String
    , email : String
    , password : String
    }

encodeNew : String -> String -> String -> E.Value
encodeNew username email password =
    E.object
      [ ( "username", E.string username)
      , ( "email", E.string email)
      , ( "password", E.string password)
      ]

decoder : D.Decoder Registration
decoder =
  D.map3 Registration
      (D.field "username" D.string)
      (D.field "email" D.string)
      (D.field "password" D.string)

maybeDecode : D.Value -> Maybe Registration
maybeDecode = JU.maybeDecode decoder

