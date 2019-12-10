FactoryBot.define do
  factory :transcription do
    user { nil }
    status { "MyString" }
    name { "MyString" }
    request { "MyText" }
    result { "MyText" }
  end
end
