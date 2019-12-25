module App.Model.Transcription where

import Prelude

import Data.Argonaut.Decode (class DecodeJson, decodeJson, (.:))
import Data.DateTime (DateTime)
import Data.Either (Either, note)
import Data.Newtype (class Newtype)
import Data.RFC3339String (RFC3339String(..), toDateTime)

type Audio =
  { filename :: String
  , content_type :: String
  , byte_size :: Number
  , url :: String
  }

newtype Transcription =
  Transcription
  { id :: Int
  , status :: String
  , created_at :: DateTime
  , audio :: Audio
  }

derive instance newtypeTranscription :: Newtype Transcription _

instance decodeJsonTranscription :: DecodeJson Transcription where
  decodeJson json = do
    obj <- decodeJson json
    id <- obj .: "id"
    status <- obj .: "status"
    created_at <- decodeDateTime =<< obj .: "created_at"
    audio <- obj .: "audio"
    pure $ Transcription { id, status, created_at, audio }

    where
      decodeDateTime :: String -> Either String DateTime
      decodeDateTime str = do
        let decodeError = "Could not decode DateTime from " <> str
        note decodeError $ toDateTime $ RFC3339String str
