module User exposing (..)

import Json.Decode as D
import Json.Utils as JU

type alias User =
    { id : String
    , email : String
    }

decoder : D.Decoder User
decoder =
  D.map2 User
      (D.field "id" D.string)
      (D.field "email" D.string)

maybeDecode : D.Value -> Maybe User
maybeDecode = JU.maybeDecode decoder
