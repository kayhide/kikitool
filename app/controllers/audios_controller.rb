class AudiosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_audio, only: [:destroy]

  def create
    current_user.audios.attach audio_params[:file]
    audio = current_user.audios_blobs.last
    transcription =
      current_user.transcriptions.create!(
        audio: audio,
        speakers_count: 2
      )
    TranscribeJob.perform_later transcription
    redirect_to :root, notice: 'Audio was successfully created.'
  rescue ActionController::ParameterMissing
    redirect_to :root, alert: 'Failed to upload.'
  end

  def destroy
    @audio.transcription_audio_attachments.destroy_all
    @audio.user_audios_attachment.destroy
    redirect_to :root, notice: 'Audio was successfully destroyed.'
  end

  private

  def set_audio
    @audio = Audio.find(params[:id])
  end

  def audio_params
    params.fetch(:audio).permit(:file, :speakers_count)
  end
end
