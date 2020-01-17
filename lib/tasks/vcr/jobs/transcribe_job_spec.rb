RSpec.describe TranscribeJob, type: :job do
  use_vcr

  subject { create :transcription, user: user, audio: user.audios_blobs.first }
  let(:user) { create :user, :with_audio }

  it "records in_progress", vcr: vcr_options("in_progress") do
    subject.put_request!
    subject.get_response!

    action = -> () {
      last = subject.response
      subject.get_response!
      subject.response != last
    }
    until action.call
      sleep 5.0 if VCR.current_cassette.recording?
    end

    status = subject.response.dig("transcription_job", "transcription_job_status")
    expect(status).to eq "IN_PROGRESS"
  end

  it "records completed", vcr: vcr_options("completed") do
    subject.put_request!
    subject.get_response!

    action = -> () {
      subject.get_response!
      subject.get_result!
      subject.result?
    }
    until action.call
      sleep 5.0 if VCR.current_cassette.recording?
    end
    status = subject.response.dig("transcription_job", "transcription_job_status")
    expect(status).to eq "COMPLETED"
  end
end
