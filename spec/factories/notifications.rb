FactoryBot.define do
  factory :notification do
    association :user
    message { "Você tem uma nova notificação" }
    read { false }
  end
end
