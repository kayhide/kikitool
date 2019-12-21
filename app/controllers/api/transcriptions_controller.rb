class Api::TranscriptionsController < ApiController
  before_action :authenticate_user!
  before_action :set_transcription, only: [:show]

  def index
    @transcriptions = current_user.transcriptions
    respond_with @transcriptions
  end

  def show
    respond_with @transcription
  end

  private

  def set_transcription
    @transcription = Transcription.find(params[:id])
  end
end
