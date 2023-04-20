module Html.Utils exposing (timeToString)

import Time

timeToString : Time.Zone -> Time.Posix -> String
timeToString timeZone time =
    String.fromInt (Time.toYear timeZone time)
        ++ "-"
        ++ zeroPaddedMonth (Time.toMonth timeZone time)
        ++ "-"
        ++ zeroPaddet (Time.toDay timeZone time)
        ++ "T"
        ++ zeroPaddet (Time.toHour timeZone time)
        ++ ":"
        ++ zeroPaddet (Time.toMinute timeZone time)

zeroPaddet : Int -> String
zeroPaddet number =
  let
      strnum = String.fromInt number
  in
      if number > 9
          then strnum
          else "0" ++ strnum

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
