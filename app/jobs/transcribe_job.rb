class TranscribeJob < ApplicationJob
  queue_as :default

  POLLING_INTERVAL = 30.seconds

  class AudioNotAttached < StandardError
    attr_reader :transcription
    def initialize transcription
      super "Audio is not attached: transcription-#{transcription.id}"
      @transcription = transcription
    end
  end

  class TranscribeServiceError < StandardError
    attr_reader :transcription
    def initialize transcription, err
      super "Bad request: transcription-#{transcription.id}, #{err.message}"
      @transcription = transcription
    end
  end

  rescue_from(AudioNotAttached) do |error|
    error.transcription.failed!
  end

  rescue_from(TranscribeServiceError) do |error|
    error.transcription.failed!
  end

  def perform transcription
    if transcription.vocabulary_filter.nil?
      CreateVocabularyFilterJob.perform_now transcription
    end

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

  rescue Aws::TranscribeService::Errors::BadRequestException => e
    raise TranscribeServiceError.new(transcription, e)
  end

  def verify! transcription
    if transcription.initialized?
      raise AudioNotAttached.new(transcription)
    end
  end
end
