class Transcription < ApplicationRecord
  include TranscriptionClient

  belongs_to :user
  has_one_attached :audio, dependent: false

  store :request
  store :response
  store :result

  STATUSES = %w(initialized attached requested completed)
  enum status: STATUSES.map { |x| [x, x] }.to_h

  before_save :update_status

  def build_request
    {
      transcription_job_name: [bucket, id].join('-'),
      language_code: "ja-JP",
      media: {
        media_file_uri: "s3://#{bucket}/#{audio.key}"
      },
      settings: {
        show_speaker_labels: true,
        max_speaker_labels: 2
      }
    }
  end

  def put_request!
    req = build_request
    super req
    self.update! request: req
  end

  def get_response!
    res = super request
    self.update! response: res.to_h
  end

  def get_result!
    res = super response
    self.update! result: res.to_h
  end

  private

  def update_status
    self.status = "initialized"
    if audio.attached?
      self.status = "attached"
      if response?
        self.status = "requested"
        if result?
          self.status ="completed"
        end
      end
    end
  end
end
