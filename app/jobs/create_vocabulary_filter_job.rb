class CreateVocabularyFilterJob < ApplicationJob
  queue_as :default

  def perform transcription
    transcription.create_vocabulary_filter!
    transcription.get_vocabulary_filter!
  end
end
