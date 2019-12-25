class Api::TranscriptionsController < ApiController
  before_action :authenticate_user!
  before_action :set_transcription, only: [:show]

  def index
    @transcriptions =
      current_user
        .transcriptions
        .with_attached_audio
        .order(id: :desc)
    respond_with @transcriptions.map(&method(:index_attributes))
  end

  def show
    respond_with show_attributes(@transcription)
  end

  private

  def set_transcription
    @transcription = Transcription.find(params[:id])
  end

  def index_attributes item
    show_attributes(item)
      .except("request", "response", "result", "vocabulary_filter")
  end

  def show_attributes item
    item.attributes.merge(
      "audio" => item.audio_blob&.attributes&.merge(
        "url" => item.audio.service_url
      )
    )
  end
end
