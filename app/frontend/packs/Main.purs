module Main where

import Prelude

import App.Api.Client as Api
import App.Utils as Utils
import App.View.Transcription as Transcription
import Data.Array as Array
import Data.Maybe (Maybe(..))
import Data.Traversable (traverse_)
import Debug.Trace (traceM)
import Effect (Effect)
import Effect.Aff (launchAff_)

main :: Effect Unit
main = do
  traceM "*****************"
  launchAff_ do
    ts <- Api.listTranscriptions
    traverse_ traceM ts
    case Array.head ts of
      Nothing -> pure unit
      Just t -> do
        t' <- Api.getTranscription t.id
        traverse_ traceM t'

init :: Effect Unit
init = do
  elms <- Utils.selectElements ".transcription"
  launchAff_ $
    traverse_ Transcription.watch elms
