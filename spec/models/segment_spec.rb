require 'rails_helper'

RSpec.describe Segment, type: :model do
  describe ".parse" do
    let(:result) { YAML.load_file fixture_path.join("transcription/result.yml") }

    it "parses result" do
      segments = Segment.parse result
      expect(segments.count).to eq 3
      expect(segments.map(&:speaker_label)).to eq %w(a a b)
      expect(segments).to all have_attributes(
        start_time: be_a(Float),
        end_time: be_a(Float),
        items: be_a(Array),
      )
      expect(segments.map(&:items).inject(:+)).to all have_attributes(
        start_time: be_a(Float),
        end_time: be_a(Float),
        content: be_a(String),
      )
    end
  end
end
