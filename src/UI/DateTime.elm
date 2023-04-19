module UI.DateTime exposing (..)

import Time

dateTime : Time.Posix -> String
dateTime time =
    zeroPaddet(Time.toYear Time.utc time) ++ "-" ++
    zeroPaddedMonth (Time.toMonth Time.utc time) ++ "-" ++
    zeroPaddet (Time.toDay Time.utc time) ++ " " ++
    zeroPaddet (Time.toHour Time.utc time) ++ ":" ++
    zeroPaddet (Time.toMinute Time.utc time) ++ ":" ++
    zeroPaddet (Time.toSecond Time.utc time)

diff : Time.Posix -> Time.Posix -> Int
diff t1 t2 = Time.posixToMillis t1 - Time.posixToMillis t2

printDiff : Int -> String
printDiff millis =
    let
      minutes = modBy 60 (millis // 60000)
      hours = millis // 3600000
    in
      zeroPaddet hours ++ ":" ++ zeroPaddet minutes

zeroPaddedMonth : Time.Month -> String
zeroPaddedMonth month =
    case month of
      Time.Jan -> "01"
      Time.Feb -> "02"
      Time.Mar -> "03"
      Time.Apr -> "04"
      Time.May -> "05"
      Time.Jun -> "06"
      Time.Jul -> "07"
      Time.Aug -> "08"
      Time.Sep -> "09"
      Time.Oct -> "10"
      Time.Nov -> "11"
      Time.Dec -> "12"

zeroPaddet : Int -> String
zeroPaddet number =
  let
      strnum = String.fromInt number
  in
      if number > 9
          then strnum
          else "0" ++ strnum
