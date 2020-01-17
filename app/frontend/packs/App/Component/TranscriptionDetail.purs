module App.Component.TranscriptionDetail where

import Prelude

import App.Api.Client as Api
import App.Model.Segment (Segment(..))
import App.Model.Segment as Segment
import App.Utils (bool)
import Data.Array as Array
import Data.Lens (_Just, _Left,  (^?))
import Data.Maybe (Maybe(..))
import Data.Traversable (traverse_)
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Effect.Exception (Error, message)
import React.Basic.DOM as R
import React.Basic.Hooks (JSX, ReactComponent, component, element, empty, useEffect, useState, (/\))
import React.Basic.Hooks as React
import React.Basic.Hooks.Aff (useAff)


type Props =
  { id :: Int
  }

mkTranscriptionDetail :: Effect (ReactComponent Props)
mkTranscriptionDetail = do
  segment_ <- mkSegmentItem
  component "SegmentDetail" \props -> React.do
    loading /\ setLoading <- useState 0
    item /\ setItem <- useState Nothing
    segments /\ setSegments <- useState []

    res <- useAff unit do
      liftEffect do
        setLoading (_ + 1)
      item' <- Api.getTranscription props.id
      liftEffect do
        setLoading (_ - 1)
        setItem $ const item'

    res' <- useAff unit do
      liftEffect do
        setLoading (_ + 1)
      segments' <- Api.listSegments props.id
      liftEffect do
        setLoading (_ - 1)
        setSegments $ const segments'

    let errors = Array.catMaybes [res ^? _Just <<< _Left, res' ^? _Just <<< _Left]
    useEffect (show <$> errors) $ do
      traverse_ (log <<< show) errors
      pure $ pure unit

    pure $
      React.fragment
      [ bool empty (renderErrors errors) (not $ Array.null errors)
      , R.div
        { className: ""
        , children: element segment_ <<< { segment: _ } <$> segments
        }
      , renderLoading $ (0 < loading) && Array.null errors
      ]

    where
      renderLoading :: Boolean -> JSX
      renderLoading loading =
        R.div
        { className: "d-flex justify-content-center position-absolute top-0 w-100 my-5" <> bool " faded" "" loading
        , children:
          [ R.div
            { className: "col text-center"
            , children:
              [ R.i { className: "fas fa-spinner fa-pulse fa-fw fa-3x text-info" }
              ]

            }
          ]
        }

      renderErrors :: Array Error -> JSX
      renderErrors errs =
        R.div_ $ renderError <$> errs

      renderError :: Error -> JSX
      renderError err =
        R.div { className: "alert alert-danger mt-3"
              , children: [ R.text $ message err ]
              }



mkSegmentItem :: Effect (ReactComponent { segment :: Segment })
mkSegmentItem  = do
  component "SegmentItem" \{ segment } -> React.do
    let (Segment seg) = segment
    pure
      $ R.div
        { className: "speaker-" <> seg.speaker_label
        , children:
          [ R.p
            { className: "glassy rounded p-3"
            , children:
              [ R.span
                { className: "badge"
                , children: [ R.text seg.speaker_label ]
                }
              ]
              <> Array.foldMap renderItem seg.items
            }
          ]
        }

    where
      renderItem :: Segment.Item -> Array JSX
      renderItem item =
        [ R.text " "
        , R.text item.content
        ]

        
