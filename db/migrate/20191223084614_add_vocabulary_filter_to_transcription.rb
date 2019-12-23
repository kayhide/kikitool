class AddVocabularyFilterToTranscription < ActiveRecord::Migration[6.0]
  def change
    add_column :transcriptions, :vocabulary_filter, :text
  end
end
