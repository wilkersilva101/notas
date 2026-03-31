FactoryBot.define do
  factory :post do
    titulo { Faker::Lorem.sentence(word_count: 5) }
    descricao { Faker::Lorem.paragraph(sentence_count: 3) }
    user # Cria um usuário automaticamente se não for fornecido
  end
end
