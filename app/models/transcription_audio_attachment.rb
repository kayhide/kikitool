class TranscriptionAudioAttachment < ActiveStorage::Attachment
  default_scope { where(record_type: "Transcription", name: "audio") }

  belongs_to :transcription, foreign_key: :record_id, dependent: :destroy
  belongs_to :audio, foreign_key: :blob_id
end
