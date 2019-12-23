require 'rails_helper'

RSpec.describe Transcription, type: :model do
  use_vcr

  describe "with aws" do
    subject { create :transcription, user: user, audio: user.audios_blobs.first }
    let(:user) { create :user, :with_audio }

    describe "transcription" do
      it "works", vcr: vcr_options("transcription") do
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

    describe "vocabulary filter" do
      before do
        VocabularyFilter.find_or_initialize_by(name: "default").update(words: <<~EOS)
        tomato
        potato
        EOS
      end

      it "works", vcr: vcr_options("vocabulary_filter") do
        subject.audio_blob.service
        subject.create_vocabulary_filter!
        subject.get_vocabulary_filter!
        expect(subject.vocabulary_filter.lines.map(&:chomp))
          .to match_array(%w(tomato potato))
      end
    end
  end

end
