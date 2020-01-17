module App.Model.Segment where

import Prelude

import Data.Argonaut.Decode (class DecodeJson, decodeJson, (.:))
import Data.Newtype (class Newtype)

type Item =
  { start_time :: Number
  , end_time :: Number
  , content :: String
  }

newtype Segment =
  Segment
  { speaker_label :: String
  , start_time :: Number
  , end_time :: Number
  , items :: Array Item
  }

derive instance newtypeSegment :: Newtype Segment _

instance decodeJsonSegment :: DecodeJson Segment where
  decodeJson json = do
    obj <- decodeJson json
    speaker_label <- obj .: "speaker_label"
    start_time <- obj .: "start_time"
    end_time <- obj .: "end_time"
    items <- obj .: "items"
    pure $ Segment { speaker_label, start_time, end_time, items }
