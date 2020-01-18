module App.Player where

import Prelude

import Effect (Effect)

foreign import data Player :: Type

foreign import create :: Array String -> Effect Player

foreign import play :: Player -> Effect Unit
foreign import pause :: Player -> Effect Unit
foreign import stop :: Player -> Effect Unit
foreign import seek :: Number -> Player -> Effect Unit

foreign import isPlaying :: Player -> Effect Boolean
foreign import getDuration :: Player -> Effect Number
foreign import getSeek :: Player -> Effect Number

foreign import onLoad :: Effect Unit -> Player -> Effect Unit
foreign import onPlay :: Effect Unit -> Player -> Effect Unit
foreign import onPause :: Effect Unit -> Player -> Effect Unit
foreign import onStop :: Effect Unit -> Player -> Effect Unit
foreign import onEnd :: Effect Unit -> Player -> Effect Unit
foreign import onSeek :: Effect Unit -> Player -> Effect Unit
