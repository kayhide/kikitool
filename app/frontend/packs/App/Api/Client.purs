module App.Api.Client where

import Prelude

import Affjax as AX
import Affjax.ResponseFormat as ResponseFormat
import App.Utils as Utils
import Data.Argonaut.Decode as Json
import Data.Array as Array
import Data.Bifunctor (lmap)
import Data.Either (either)
import Data.Maybe (Maybe(..))
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Aff (Aff)
import App.Model.Transcription as Model
import Web.DOM.HTMLCollection as Dom
import Web.DOM.ParentNode as Dom
import Web.HTML as HTML
import Web.HTML.HTMLDocument as Document
import Web.HTML.HTMLElement as Element
import Web.HTML.HTMLMetaElement as Meta
import Web.HTML.Window as Window



lookupAuthenticityToken :: Effect (Maybe { name :: String, value :: String })
lookupAuthenticityToken = do
  doc <- Window.document =<< HTML.window
  head <- Document.head doc
  case head of
    Nothing -> pure Nothing
    Just head' -> do
      elms <- Dom.children $ Element.toParentNode head'
      metas <- Array.catMaybes <<< map Meta.fromElement <$> Dom.toArray elms
      contents <-
        traverse (\elm -> { name: _, content: _ }
                          <$> Meta.name elm
                          <*> Meta.content elm
                 ) metas
      pure $ do
        name <- _.content <$> Array.find ((==) "csrf-param" <<< _.name) contents
        value <- _.content <$> Array.find ((==) "csrf-token" <<< _.name) contents
        pure { name, value }


listTranscriptions :: Aff (Array Model.Transcription)
listTranscriptions = do
  res <- AX.get ResponseFormat.json "/api/transcriptions"
  either Utils.onError pure $ do
    res' <- lmap AX.printError res
    Json.decodeJson res'.body


getTranscription :: Int -> Aff (Maybe Model.Transcription)
getTranscription id = do
  res <- AX.get ResponseFormat.json $ "/api/transcriptions/" <> show id
  either Utils.onError pure $ do
    res' <- lmap AX.printError res
    Json.decodeJson res'.body
