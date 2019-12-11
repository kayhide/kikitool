class Audio < ActiveStorage::Blob
  has_one :user_audios_attachment, foreign_key: :blob_id
  has_one :user, through: :user_audios_attachment
  has_one :transcription_audio_attachment, foreign_key: :blob_id
  has_one :transcription, through: :transcription_audio_attachment

  def blob
    becomes(self.class.superclass)
  end
end
