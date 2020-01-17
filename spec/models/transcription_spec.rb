require 'rails_helper'

RSpec.describe Transcription, type: :model do
  use_vcr

  describe "with aws" do
    subject { create :transcription, user: user, audio: user.audios_blobs.first }
    let(:user) { create :user, :with_audio }

    describe "transcription", vcr: vcr_options("transcription") do
      it "works", :play_only do
        subject.put_request!
        until subject.result?
          subject.get_response!
          subject.get_result!
        end
        status = subject.response.dig("transcription_job", "transcription_job_status")
        expect(status).to eq "COMPLETED"
      end
    end

    describe "vocabulary filter", vcr: vcr_options("vocabulary_filter") do
      before do
        VocabularyFilter.find_or_initialize_by(name: "default").update(words: <<~EOS)
        tomato
        potato
        EOS
      end

      it "works" do
        subject.create_vocabulary_filter!
        subject.get_vocabulary_filter!
        expect(subject.vocabulary_filter.lines.map(&:chomp))
          .to match_array(%w(tomato potato))
      end
    end
  end

end
