class UserAudiosAttachment < ActiveStorage::Attachment
  default_scope { where(record_type: "User", name: "audios") }

  belongs_to :user, foreign_key: :record_id
  belongs_to :audio, foreign_key: :blob_id
end
