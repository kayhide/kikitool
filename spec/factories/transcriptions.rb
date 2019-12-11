FactoryBot.define do
  factory :transcription do
    user
    status { nil }
    request { nil }
    response { nil }
    result { nil }

    transient do
      audio_file { nil }
    end

    trait :with_audio do
      transient do
        audio_file { "files/visby.mp3" }
      end
    end

    after :create do |record, options|
      extend ActiveJob::TestHelper
      if options.audio_file
        file = RSpec.configuration.fixture_path.join(options.audio_file)
        perform_enqueued_jobs do
          record.audio.attach(io: file.open, filename: file.basename)
        end
        record.reload
      end
    end
  end
end
