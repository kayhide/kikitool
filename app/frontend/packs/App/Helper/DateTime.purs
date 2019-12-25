module App.Helper.DateTime where

import Prelude

import Data.DateTime (DateTime(..))
import Data.Formatter.DateTime (Formatter, FormatterCommand(..), format)
import Data.List (List(..), (:))

toDefaultDateTime :: DateTime -> String
toDefaultDateTime dt = format f dt
  where
    f :: Formatter
    f = YearFull
        : Placeholder "/"
        : MonthTwoDigits
        : Placeholder "/"
        : DayOfMonthTwoDigits
        : Placeholder " "
        : Hours24
        : Placeholder ":"
        : MinutesTwoDigits
        : Placeholder ":"
        : SecondsTwoDigits
        : Nil
