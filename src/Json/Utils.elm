module Json.Utils exposing (..)

import Json.Decode as D

maybeDecode : D.Decoder a -> D.Value -> Maybe a
maybeDecode decoder value =
    case D.decodeValue decoder value of
        Ok decoded -> Just decoded
        Err _ -> Nothing
