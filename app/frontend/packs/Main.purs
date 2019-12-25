module Main where

import Prelude

import App.Utils as Utils
import Data.Traversable (traverse_)
import Effect (Effect)
import Effect.Class.Console (log)
import React.Basic.DOM (render)
import React.Basic.Hooks (element)
import TranscriptionList (mkTranscriptionList)

init :: Effect Unit
init = do
  log "*****************"
  Utils.selectElements "#transcription-list"
  >>= traverse_ \c -> do
    list_ <- mkTranscriptionList
    render (element list_ {}) c
