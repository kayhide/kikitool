
module TranscriptionList where

import Prelude

import App.Api.Client as Api
import App.Helper.ByteSize (toHumanByteSize)
import App.Helper.DateTime (getTimezone, toDateTimeIn, toDefaultDateTime)
import App.Model.Transcription (Transcription(..))
import Control.MonadPlus (guard)
import Data.Either (either)
import Data.Maybe (Maybe(..), isJust, maybe)
import Effect (Effect)
import Effect.Aff (Milliseconds(..), delay)
import Effect.Class (liftEffect)
import Effect.Exception (Error)
import Foreign.Object as FO
import React.Basic.DOM as R
import React.Basic.Hooks (JSX, ReactComponent, component, element, useState, (/\))
import React.Basic.Hooks as React
import React.Basic.Hooks.Aff (useAff)

mkTranscriptionList :: Effect (ReactComponent {})
mkTranscriptionList = do
  item <- mkTranscriptionItem
  component "TranscriptionList" \props -> React.do
    res <- useAff unit Api.listTranscriptions

    let render transcriptions =
          R.div { className: "row"
                , children:
                  (element item <<< { transcription: _ }) <$> transcriptions
                }

    pure $ maybe renderLoading (either renderError render) res

    where
      renderLoading :: JSX
      renderLoading =
        R.div
        { className: "row"
        , children:
          [ R.div
            { className: "col p-2"
            , children:
              [ R.p
                { className: "text-center my-5"
                , children:
                  [ R.i { className: "fas fa-spinner fa-pulse fa-fw fa-3x text-info" }
                  ]
                }
              ]
            }
          ]
        }

      renderError :: Error -> JSX
      renderError err =
        R.div { className: "alert alert-info"
              , children: [ R.text $ show err ]
              }

mkTranscriptionItem :: Effect (ReactComponent { transcription :: Transcription })
mkTranscriptionItem  = do
  status_ <- mkTranscriptionStatus
  tz <- getTimezone
  component "TranscriptionItem" \{ transcription } -> React.do
    let (Transcription t) = transcription
    pure
      $ R.div
        { className: "col-sm-6 col-lg-3 p-2"
        , children:
          [ R.div
            { className: "card glassy-light transcription"
            , id: "3"
            , children:
              [ R.div
                { className: "card-body"
                , children:
                  [ R.p_
                    [ R.i { className: "fas fa-play-circle fa-fw" }
                    , R.text " "
                    , R.a
                      { href: "#"
                      , _data: FO.fromHomogeneous { sound: t.audio.url }
                      , children:
                        [ R.u_ $ [ R.text t.audio.filename ] ]
                      }]
                  , R.p_
                    [ R.i { className: "fas fa-database fa-fw" }
                    , R.text " "
                    , R.text $ toHumanByteSize t.audio.byte_size
                    ]
                  , R.p_
                    [ R.i { className: "far fa-clock fa-fw" }
                    , R.text " "
                    , R.text $ toDateTimeIn tz t.created_at
                    ]
                  , element status_ { transcription }
                  ]}]}]}

mkTranscriptionStatus :: Effect (ReactComponent { transcription :: Transcription })
mkTranscriptionStatus = do
  component "TranscriptionStatus" \{ transcription } -> React.do
    let (Transcription t) = transcription
    polling /\ setPolling <- useState $ 0 <$ guard (t.status /= "completed")
    status /\ setStatus <- useState t.status
    _ <- useAff polling $
      when (isJust polling) do
        delay $ Milliseconds 3000.0
        res' <- Api.getTranscription t.id
        liftEffect $
          case res' of
            Nothing ->
              setPolling $ const Nothing
            Just (Transcription t') -> do
              setStatus $ const t'.status
              setPolling $ case t'.status of
                "completed" -> const Nothing
                _ -> map (_ + 1)

    pure $ case status of
      "completed" ->
        R.p_
        [ R.i { className: "fas fa-check fa-fw text-success" }
        , R.text " "
        , R.a
          { href: "/transcriptions/" <> show t.id
          , children:
            [ R.u_ $ [ R.text status ] ]
          }]
      _ ->
        R.p_
        [ R.i { className: "fas fa-spinner fa-pulse fa-fw text-info" }
        , R.text " "
        , R.text status
        ]
