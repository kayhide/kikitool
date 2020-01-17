FactoryBot.define do
  factory :user do
    sequence(:username) { |i| "User #{i}" }
    sequence(:email) { |i| "user-#{i}@kikitool.test" }
    sequence(:password) { |i| "password-#{i}" }

    transient do
      audio_file { nil }
      ready? { false }
    end

    trait :with_audio do
      transient do
        audio_file { "files/visby.mp3" }
      end
    end

    after :create do |user, options|
      extend ActiveJob::TestHelper
      if options.audio_file
        file = RSpec.configuration.fixture_path.join(options.audio_file)
        perform_enqueued_jobs do
          user.audios.attach(io: file.open, filename: file.basename)
        end
        user.reload
      end
    end
  end
end
