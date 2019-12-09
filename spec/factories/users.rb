FactoryBot.define do
  factory :user do
    sequence(:username) { |i| "User 1" }
    sequence(:email) { |i| "user-#{i}@kikitool.test" }
  end
end
