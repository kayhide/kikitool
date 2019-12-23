require 'rails_helper'

RSpec.describe TranscribeJob, type: :job do
  describe "#perform" do
    use_vcr

    before do
      allow(CreateVocabularyFilterJob).to receive(:perform_now)
    end

    context "without vocabulary_filter", vcr: vcr_options("in_progress") do
      let(:transcription) { create :transcription, :with_audio, vocabulary_filter: "ajo" }

      it "skips CreateVocabularyFilterJob" do
        expect(CreateVocabularyFilterJob).not_to receive(:perform_now)
        subject.perform transcription
      end
    end


    context "with audio", vcr: vcr_options("in_progress") do
      let(:transcription) { create :transcription, :with_audio }

      it "performs CreateVocabularyFilterJob" do
        expect(CreateVocabularyFilterJob).to receive(:perform_now)
        subject.perform transcription
      end

      it "saves response" do
        expect(transcription).to be_attached
        expect {
          subject.perform transcription
        }.to change { transcription.reload.response? }.to(true)
      end
    end

    context "with requested" do
      let(:transcription) { create :transcription, :with_audio }

      context "in progress", vcr: vcr_options("in_progress") do
        before do
          transcription.put_request!
          transcription.get_response!
        end

        it "updates response" do
          expect(transcription).to be_requested
          expect {
            subject.perform transcription
          }.to change { transcription.reload.response }
        end

        it "enqueues TranscribeJob" do
          expect(transcription).to be_requested
          freeze_time do
            expect {
              subject.perform transcription
            }.to have_enqueued_job(TranscribeJob)
                   .with(transcription)
                   .at(30.seconds.from_now)
          end
        end
      end

      context "completed", vcr: vcr_options("completed") do
        before do
          transcription.put_request!
          transcription.get_response!
        end

        it "saves result" do
          expect(transcription).to be_requested
          expect {
            subject.perform transcription
          }.to change { transcription.reload.result? }.to(true)
        end
      end
    end

    context "without audio" do
      let(:transcription) { create :transcription }

      it "raises AudioNotAttached" do
        expect {
          subject.perform transcription
        }.to raise_error(TranscribeJob::AudioNotAttached)
      end
    end
  end
end
