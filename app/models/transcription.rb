class Transcription < ApplicationRecord
  include TranscriptionClient

  belongs_to :user
  has_one_attached :audio, dependent: false

  validates :speakers_count, presence: true

  store :request
  store :response
  store :result

  STATUSES = %w(initialized attached requested completed)
  enum status: STATUSES.map { |x| [x, x] }.to_h

  LANGUAGE = "ja-JP"

  before_save :update_status

  def name
    [bucket, id].join('-')
  end

  def build_request
    {
      transcription_job_name: name,
      language_code: LANGUAGE,
      media: {
        media_file_uri: "s3://#{bucket}/#{audio.key}"
      },
      settings: {
        show_speaker_labels: true,
        max_speaker_labels: 2,
      }.merge(
        vocabulary_filter? ?
          {
            vocabulary_filter_name: name,
            vocabulary_filter_method: "remove"
          } : {}
      )
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


  def create_vocabulary_filter!
    super(
      vocabulary_filter_name: name,
      language_code: LANGUAGE,
      words: VocabularyFilter.find_by(name: "default").word_list
    )
  end

  def get_vocabulary_filter!
    text = super(vocabulary_filter_name: name)
    self.update! vocabulary_filter: text
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
