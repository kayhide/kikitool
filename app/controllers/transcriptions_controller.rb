class TranscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_transcription

  def show
  end

  private

  def set_transcription
    @transcription = Transcription.find(params[:id])
  end
end
