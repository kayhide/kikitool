class Audio < ActiveStorage::Blob
  has_one :user_audios_attachment, foreign_key: :blob_id
  has_one :user, through: :user_audios_attachment
  has_many :transcription_audio_attachments, foreign_key: :blob_id
  has_many :transcriptions, through: :transcription_audio_attachments

  def blob
    becomes(self.class.superclass)
  end
end
