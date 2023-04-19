module Html.Utils exposing (..)

import Time
import Iso8601

timeToString : Time.Posix -> String
timeToString time = String.slice 0 -8 (Iso8601.fromTime time)
