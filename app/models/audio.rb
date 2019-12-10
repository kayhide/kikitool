class Audio < ActiveStorage::Blob
  has_one :user_audios_attachment, foreign_key: :blob_id
  has_one :user, through: :user_audios_attachment
end
