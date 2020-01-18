module App.Component.TranscriptionDetail where

import Prelude

import App.Api.Client as Api
import App.Helper.Duration (formatDuration)
import App.Model.Segment (Segment(..))
import App.Model.Segment as Segment
import App.Model.Transcription (Transcription(..))
import App.Player (Player)
import App.Player as Player
import App.Utils (bool)
import Data.Array as Array
import Data.Lens (_Just, _Left, (^?))
import Data.Maybe (Maybe(..))
import Data.Traversable (traverse, traverse_)
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Effect.Exception (Error, message)
import Effect.Timer as Timer
import React.Basic.DOM as R
import React.Basic.Events (handler_)
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
    useEffect (show <$> errors) do
      traverse_ (log <<< show) errors
      pure $ pure unit


    player /\ setPlayer <- useState Nothing
    playing /\ setPlaying <- useState false
    duration /\ setDuration <- useState 0.0
    position /\ setPosition <- useState 0.0

    useEffect item do
      item # traverse_ \(Transcription t) -> do
        player' <- Player.create [t.audio.url]
        setPlayer $ const $ pure player'
        player' # Player.onLoad (setDuration <<< const =<< Player.getDuration player')
        [Player.onPlay, Player.onPause, Player.onStop, Player.onEnd] # traverse_ \on ->
          player' # on (setPlaying <<< const =<< Player.isPlaying player')
        player' # Player.play
        player' # Player.stop
      pure $ pure unit

    useEffect playing do
      id <- player # traverse \player' -> do
        Timer.setInterval 100 do
          setPosition <<< const =<< Player.getSeek player'
      pure do
        traverse_ Timer.clearInterval id

    pure $
      React.fragment
      [ bool empty (renderErrors errors) (not $ Array.null errors)
      , R.div
        { className: ""
        , children: element segment_ <<< { segment: _, player, position } <$> segments
        }
      , renderLoading $ (0 < loading) && Array.null errors
      , renderPlayer playing position duration player
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
        R.div
        { className: "alert alert-danger mt-3"
        , children: [ R.text $ message err ]
        }

      renderPlayer :: Boolean -> Number -> Number -> Maybe Player -> JSX
      renderPlayer playing position duration player =
        R.div
        { className: "bottom-player"
        , children:
          [ R.div
            { className: "d-flex align-items-center p-1"
            , children:
              [ renderPlayButton playing player
              , R.span
                { className: "text-monospace text-right ml-auto"
                , children:
                  [ R.text
                    $ formatDuration position <> " / " <> formatDuration duration
                  ]
                }
              ]
            }
          , R.div
            { className: "progress"
            , children:
              [ R.div
                { className: "progress-bar bg-info"
                , style: R.css { width: show (position / duration * 100.0) <> "%" }
                }
              ]
            }
          ]
        }

      renderPlayButton :: Boolean -> Maybe Player -> JSX
      renderPlayButton playing player =
        R.a
        { className: "btn btn-outline-light btn-sm" <> bool "" " active" playing
        , onClick: handler_ $ player # traverse_
            (bool Player.play Player.pause playing)
        , children:
          [ R.i { className: "fas fa-play" } ]
        }


mkSegmentItem :: Effect (ReactComponent { segment :: Segment, player :: Maybe Player, position :: Number })
mkSegmentItem  = do
  component "SegmentItem" \{ segment, player, position } -> React.do
    let (Segment seg) = segment
    pure
      $ R.div
        { className: "segment speaker-" <> seg.speaker_label
          <> bool "" " playing" (seg.start_time <= position && position < seg.end_time)
        , children:
          [ R.p
            { className: "glassy rounded p-3"
            , children:
              [ renderSpeakerLabel segment player
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

      renderSpeakerLabel :: Segment -> Maybe Player -> JSX
      renderSpeakerLabel (Segment { speaker_label, start_time }) player = do
        let children = [ R.text speaker_label ]
        R.a
            { className: "badge stretched-link"
            , href: "#" <> show start_time
            , onClick: handler_ $ player # traverse_ \p -> do
                Player.seek start_time p
                Player.play p
            , children: [ R.text speaker_label ]
            }
