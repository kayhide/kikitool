require 'rails_helper'

RSpec.describe CreateVocabularyFilterJob, type: :job do
  describe "#perform" do
    use_vcr

    let(:transcription) { create :transcription }

    context "with default filter", vcr: vcr_options("default") do
      before do
        VocabularyFilter.find_or_initialize_by(name: "default").update(words: <<~EOS)
        tomato
        potato
        EOS
      end

      it "sets transcription#vocabulary_filter" do
        expect {
          subject.perform transcription
        }.to change { transcription.reload.vocabulary_filter }.from(nil)
        expect(transcription.vocabulary_filter.lines.map(&:chomp))
          .to match_array(%w(tomato potato))
      end
    end
  end
end
