module App.Helper.ByteSize where

import Prelude

import Data.Formatter.Number (Formatter(..), format)
import Data.Int (fromNumber)
import Data.List.Lazy (List, fromFoldable, iterate, last, takeWhile, zip)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Tuple (Tuple(..), fst)
import Math as Math

toHumanByteSize :: Number -> String
toHumanByteSize x = case last (takeWhile ((1.0 <= _) <<< fst) xs) of
  Nothing -> show x <> " " <> "B"
  Just (Tuple x' u') -> (format' x') <> " " <> u'
  where
    xs :: List (Tuple Number String)
    xs = zip (iterate (_ / 1024.0) x) units

    units :: List String
    units = fromFoldable ["B", "KB", "MB", "GB", "TB", "EB"]

    format' :: Number -> String
    format' x' = format f x'
      where
        digits :: Number
        digits = Math.floor $ Math.log x' * Math.log10e

        f :: Formatter
        f = Formatter
            { comma: false
            , before: 0
            , after: 2 - fromMaybe 0 (fromNumber digits)
            , abbreviations: false
            , sign: false
            }
