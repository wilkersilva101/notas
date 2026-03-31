FactoryBot.define do
  factory :notification do
    user { nil }
    message { "MyString" }
    read { false }
  end
end
