module TranscriptionClient
  extend ActiveSupport::Concern

  module ClassMethods
    def client
      @client ||= Aws::TranscribeService::Client.new
    end

    def bucket
      @bucket ||= ActiveStorage::Blob.service.bucket.name
    end
  end

  def bucket
    self.class.bucket
  end

  def put_request! request
    self.class.client.start_transcription_job request
  end

  def get_response! request
    self.class.client.get_transcription_job request.slice(:transcription_job_name)
  end

  def get_result! response
    uri = response.dig(:transcription_job, :transcript, :transcript_file_uri)
    if uri
      open(uri, &JSON.method(:load))
    end
  end

  def create_vocabulary_filter! args
    self.class.client.create_vocabulary_filter args
  end

  def get_vocabulary_filter! args
    res = self.class.client.get_vocabulary_filter args
    uri = res.download_uri
    if uri
      open(uri, &:read)
    end
  end
end
