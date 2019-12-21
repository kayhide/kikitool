module App.Utils where

import Prelude

import Control.Plus (class Plus, empty)
import Effect.Class (class MonadEffect)
import Effect.Class.Console (log)


onError
  :: forall m f a.
     MonadEffect m =>
     Plus f =>
     String -> m (f a)
onError msg = do
  log msg
  pure empty
