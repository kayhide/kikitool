class CreateTranscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :transcriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false
      t.string :name
      t.text :request
      t.text :response
      t.text :result

      t.timestamps
    end
  end
end
