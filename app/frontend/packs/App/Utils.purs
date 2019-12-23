module App.Utils where

import Prelude

import Control.Plus (class Plus, empty)
import Data.Array as Array
import Effect (Effect)
import Effect.Class (class MonadEffect)
import Effect.Class.Console (log)
import Web.DOM.Element (Element)
import Web.DOM.Element as Element
import Web.DOM.NodeList (toArray)
import Web.DOM.ParentNode (QuerySelector(..), querySelectorAll)
import Web.HTML as HTML
import Web.HTML.HTMLDocument (toParentNode)
import Web.HTML.Window as Window


onError
  :: forall m f a.
     MonadEffect m =>
     Plus f =>
     String -> m (f a)
onError msg = do
  log msg
  pure empty


selectElements :: String -> Effect (Array Element)
selectElements q = do
  doc <- Window.document =<< HTML.window
  elms <- toArray =<< querySelectorAll (QuerySelector q) (toParentNode doc)
  pure $ Array.catMaybes $ Element.fromNode <$> elms
