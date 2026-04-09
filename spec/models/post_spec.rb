# Carrega o ambiente do Rails para o teste (obrigatório em todo spec de modelo)
require 'rails_helper'

# RSpec.describe: Define o que estamos testando (a classe Post)
# type: :model informa ao RSpec que este é um teste de modelo
RSpec.describe Post, type: :model do
  # "describe" agrupa testes relacionados a uma mesma funcionalidade.
  # Pense como um título de seção: "Aqui testamos as VALIDAÇÕES do Post"
  describe "validations" do
    # "let" define uma variável de teste que é criada apenas quando usada.
    # É "lazy" (preguiçosa): só executa quando o teste precisar dela.
    # Aqui criamos um usuário no banco de dados de teste usando a factory :user
    let(:user) { create(:user) }

    # "subject" define o objeto principal que estamos testando em todo o bloco.
    # "build" cria o objeto na memória mas NÃO salva no banco de dados.
    # Isso é importante: evitamos acessar o banco quando não é necessário.
    subject { build(:post, user: user) }

    # --------------------------------------------------
    # TESTE 1: Caminho feliz (Happy Path)
    # Garante que nossa factory está configurada corretamente
    # e que um Post com dados válidos passa na validação.
    # --------------------------------------------------
    it "is valid with valid attributes" do
      # "expect(...).to be_valid" verifica se o objeto não tem erros de validação
      expect(subject).to be_valid
    end

    # --------------------------------------------------
    # TESTE 2: Ausência de usuário
    # O Post pertence a um User (belongs_to :user).
    # Por padrão no Rails, belongs_to já exige a presença do objeto pai.
    # --------------------------------------------------
    it "is not valid without a user" do
      subject.user = nil # Removemos o usuário para forçar o erro

      # "to_not be_valid" é o oposto: esperamos que o objeto seja INVÁLIDO
      expect(subject).to_not be_valid
    end

    # --------------------------------------------------
    # TESTE 3: Presença do título
    # O modelo Post tem `validates :titulo, presence: true`
    # Este teste garante que essa regra de negócio está funcionando.
    # --------------------------------------------------
    it "is not valid without a titulo" do
      subject.titulo = nil # Forçamos o título a ser nulo

      # Esperamos que o objeto falhe na validação
      expect(subject).to_not be_valid
    end
  end

  # --------------------------------------------------
  # Segundo grupo: Testamos as ASSOCIAÇÕES do modelo
  # --------------------------------------------------
  describe "associations" do
    # Verifica se a associação "belongs_to :user" está definida no modelo.
    # "reflect_on_association" é um método do Rails que inspeciona as associações
    # sem precisar criar objetos ou tocar no banco de dados.
    it "belongs to a user" do
      # Retorna um objeto com os metadados da associação
      association = described_class.reflect_on_association(:user)

      # ".macro" retorna o tipo da associação (:belongs_to, :has_many, etc.)
      expect(association.macro).to eq(:belongs_to)
    end
  end

  # --------------------------------------------------
  # Terceiro grupo: Testamos métodos de classe Ransack
  # Métodos de classe são definidos com self.nome_do_metodo
  # --------------------------------------------------
  describe ".ransackable_attributes" do
    it "returns the list of searchable attributes" do
      expected_attributes = [ "created_at", "descricao", "id", "titulo", "updated_at", "user_id" ]
      expect(described_class.ransackable_attributes).to eq(expected_attributes)
    end

    it "accepts an optional auth_object parameter" do
      expect { described_class.ransackable_attributes(nil) }.not_to raise_error
      expect { described_class.ransackable_attributes("admin") }.not_to raise_error
    end
  end

  describe ".ransackable_associations" do
    it "returns the list of searchable associations" do
      expected_associations = [ "user" ]
      expect(described_class.ransackable_associations).to eq(expected_associations)
    end

    it "accepts an optional auth_object parameter" do
      expect { described_class.ransackable_associations(nil) }.not_to raise_error
      expect { described_class.ransackable_associations("admin") }.not_to raise_error
    end
  end
end
