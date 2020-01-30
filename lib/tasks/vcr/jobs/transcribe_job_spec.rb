RSpec.describe TranscribeJob, type: :job do
  use_vcr

  let(:transcription) { create :transcription, user: user, audio: user.audios_blobs.first }
  let(:user) { create :user, :with_audio }

  it "records in_progress", vcr: vcr_options("in_progress") do
    transcription.put_request!
    transcription.get_response!

    action = -> () {
      last = transcription.response
      transcription.get_response!
      transcription.response != last
    }
    until action.call
      sleep 5.0 if VCR.current_cassette.recording?
    end

    status = transcription.response.dig("transcription_job", "transcription_job_status")
    expect(status).to eq "IN_PROGRESS"
  end

  it "records completed", vcr: vcr_options("completed") do
    transcription.put_request!
    transcription.get_response!

    action = -> () {
      transcription.get_response!
      transcription.get_result!
      transcription.result?
    }
    until action.call
      sleep 5.0 if VCR.current_cassette.recording?
    end
    status = transcription.response.dig("transcription_job", "transcription_job_status")
    expect(status).to eq "COMPLETED"
  end

  it "records bad_request", vcr: vcr_options("bad_request") do
    req = transcription.build_request
    req[:settings][:max_speaker_labels] = 1
    allow(transcription).to receive(:build_request) { req }
    expect {
      transcription.put_request!
    }.to raise_error(Aws::TranscribeService::Errors::BadRequestException)
  end
end
