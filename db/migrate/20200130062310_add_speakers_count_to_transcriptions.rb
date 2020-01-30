class AddSpeakersCountToTranscriptions < ActiveRecord::Migration[6.0]
  def change
    add_column :transcriptions, :speakers_count, :integer
    reversible do |dir|
      dir.up do
        Transcription.update_all speakers_count: 2
      end
    end
  end
end
