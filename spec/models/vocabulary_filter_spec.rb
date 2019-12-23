require 'rails_helper'

RSpec.describe VocabularyFilter, type: :model do
  describe "#word_list" do
    it "returns a list from words" do
      subject.words = <<~EOS
      tomato
      potato
      EOS
      expect(subject.word_list).to eq %w(tomato potato)
    end
  end

  describe "#word_list=" do
    it "sets words" do
      subject.word_list = %w(tomato potato)
      expect(subject.words).to eq <<~EOS
      tomato
      potato
      EOS
    end
  end
end
