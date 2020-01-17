class Api::Transcriptions::SegmentsController < ApiController
  before_action :authenticate_user!
  before_action :set_transcription

  def index
    segments = Segment.parse(@transcription.result)
    respond_with segments
  end

  private

  def set_transcription
    @transcription = Transcription.find(params[:transcription_id])
  end
end
