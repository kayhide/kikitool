module Main where

import Prelude

import App.Component.TranscriptionDetail (mkTranscriptionDetail)
import App.Component.TranscriptionList (mkTranscriptionList)
import App.Utils (throwOnNothing)
import App.Utils as Utils
import Data.Int as Int
import Data.Traversable (traverse_)
import Effect (Effect)
import Effect.Class.Console (log)
import React.Basic.DOM (render)
import React.Basic.Hooks (element)

init :: Effect Unit
init = do
  log "*****************"
  Utils.selectElements "#transcription-list"
    >>= traverse_ \elm -> do
      cmp <- mkTranscriptionList
      render (element cmp {}) elm
  Utils.selectElements "#transcription-detail"
    >>= traverse_ \elm -> do
      cmp <- mkTranscriptionDetail
      id <- do
        Utils.lookupDataset "id" elm
          >>= throwOnNothing "Dataset id is missing"
          >>= Int.fromString
          >>> throwOnNothing "Invalid id"
      render (element cmp { id }) elm
