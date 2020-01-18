module App.Helper.Duration where

import Prelude

import App.Utils (bool)
import Data.Array as Array
import Data.Either (fromRight)
import Data.Formatter.Number (format, parseFormatString)
import Data.Int as Int
import Partial.Unsafe (unsafePartial)


formatDuration :: Number -> String
formatDuration d =
  Array.intercalate ":"
  $ bool identity (Array.cons h) (3600.0 < d) [m, s]
  where
    h = bool (const "") show =<< (0 < _) $ (Int.floor d `div` 3600)
    m =
      format
      (unsafePartial $ fromRight $ parseFormatString "00")
      $ Int.toNumber $ Int.floor d `mod` 3600 `div` 60
    s =
      format
      (unsafePartial $ fromRight $ parseFormatString "00")
      $ Int.toNumber $ Int.floor d `mod` 60
