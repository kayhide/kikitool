class TranscribeJob < ApplicationJob
  queue_as :default

  POLLING_INTERVAL = 30.seconds

  class AudioNotAttached < StandardError
    attr_reader :transcription
    def initialize transcription
      super "Audio is not attached: transcription-#{transcription}"
      @transcription = transcription
    end
  end

  def perform transcription
    verify! transcription

    if transcription.attached?
      transcription.put_request!
      transcription.get_response!
    elsif transcription.requested?
      transcription.get_response!
      transcription.get_result!
    end

    unless transcription.completed?
      TranscribeJob.set(wait: POLLING_INTERVAL).perform_later(transcription)
    end
  end

  def verify! transcription
    if transcription.initialized?
      raise AudioNotAttached.new(transcription)
    end
  end
end
