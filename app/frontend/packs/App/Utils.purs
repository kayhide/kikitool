module App.Utils where

import Prelude

import Control.Plus (class Plus, empty)
import Data.Array as Array
import Data.Either (Either, either, note)
import Data.Maybe (Maybe)
import Data.Nullable (Nullable)
import Data.Nullable as Nullable
import Effect (Effect)
import Effect.Class (class MonadEffect)
import Effect.Class.Console (log)
import Effect.Exception (throw)
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


foreign import _lookupDataset :: String -> Element -> Effect (Nullable String)

lookupDataset :: String -> Element -> Effect (Maybe String)
lookupDataset key elm = Nullable.toMaybe <$> _lookupDataset key elm



bool :: forall a. a -> a -> Boolean -> a
bool x y b = if b then y else x

throwOnNothing :: forall a. String -> Maybe a -> Effect a
throwOnNothing msg = throwOnLeft <<< note msg

throwOnLeft :: forall a. Either String a -> Effect a
throwOnLeft = either throw pure
