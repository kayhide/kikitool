class RemoveNameFromTranscriptions < ActiveRecord::Migration[6.0]
  def change

    remove_column :transcriptions, :name, :string
  end
end
