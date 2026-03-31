FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    username { Faker::Internet.unique.username }
    password { "password123" }
    password_confirmation { "password123" }

    after(:create) do |user|
      user.add_role(:basic) if user.roles.blank?
    end

    trait :admin do
      after(:create) do |user|
        user.roles.destroy_all
        user.add_role(:admin)
      end
    end
  end
end
