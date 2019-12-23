class CreateVocabularyFilters < ActiveRecord::Migration[6.0]
  def change
    create_table :vocabulary_filters do |t|
      t.string :name, null: false
      t.text :words, null: false

      t.timestamps
    end
  end
end
