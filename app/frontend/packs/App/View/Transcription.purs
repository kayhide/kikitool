module App.View.Transcription where

import Prelude

import App.Api.Client as Api
import Data.Array as Array
import Data.Int as Int
import Data.String as String
import Data.Traversable (traverse)
import Debug.Trace (traceM)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Web.DOM.Element (Element)
import Web.DOM.Element as Element

watch :: Element -> Aff Unit
watch elm = do
  id  <- liftEffect $ Element.id elm
  let id' =
        String.split (String.Pattern "_") id
        # Array.last
        >>= Int.fromString

  t <- join <$> traverse Api.getTranscription id'
  traceM t
