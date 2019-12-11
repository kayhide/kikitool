require 'rails_helper'

RSpec.describe Transcription, type: :model do
  use_vcr

  describe "with aws" do
    subject { create :transcription, user: user, audio: user.audios_blobs.first }
    let(:user) { create :user, :with_audio }

    it "works", vcr: vcr_options("works") do
      subject.audio_blob.service
      subject.put_request!

      until subject.result?
        subject.get_response!
        subject.get_result!
        if VCR.current_cassette.recording? && !subject.result?
          puts
          puts "recording..."
          sleep 30
        end
      end
    end
  end
end
