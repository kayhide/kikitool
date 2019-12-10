FactoryBot.define do
  factory :transcription do
    user
    status { nil }
    request { nil }
    response { nil }
    result { nil }
  end
end
