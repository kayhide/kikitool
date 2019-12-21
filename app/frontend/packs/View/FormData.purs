module View.FormData where

import Effect (Effect)
import Web.DOM.Element (Element)
import Web.XHR.FormData (FormData)

foreign import fromElement :: Element -> Effect FormData
