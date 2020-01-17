module App.Helper.DateTime where

import Prelude

import Data.DateTime (DateTime, adjust)
import Data.Formatter.DateTime (Formatter, FormatterCommand(..), format)
import Data.JSDate as JSDate
import Data.List (List(..), (:))
import Data.Maybe (maybe)
import Data.Time.Duration as D
import Effect (Effect)

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

toDateTimeIn :: Timezone -> DateTime -> String
toDateTimeIn (Timezone offset) dt = maybe "???" toDefaultDateTime $ adjust offset dt


newtype Timezone = Timezone D.Minutes

getTimezone :: Effect Timezone
getTimezone = do
  now <- JSDate.now
  Timezone <<< D.Minutes <$> JSDate.getTimezoneOffset now
