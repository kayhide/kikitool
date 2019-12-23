class VocabularyFilter < ApplicationRecord

  def word_list
    words.lines.map(&:strip)
  end

  def word_list= arg
    self.words = arg.map(&:strip).join("\n") + "\n"
  end
end
