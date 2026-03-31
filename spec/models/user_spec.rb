# Carrega o ambiente do Rails para o teste (obrigatório em todo spec de modelo)
require 'rails_helper'

# RSpec.describe: Define o que estamos testando (a classe User)
# type: :model informa ao RSpec que este é um teste de modelo
RSpec.describe User, type: :model do

  # "describe" agrupa testes relacionados a uma mesma funcionalidade.
  # Pense como um título de seção: "Aqui testamos as VALIDAÇÕES do User"
  describe "validations" do

    # "subject" define o objeto principal que será usado nos testes do bloco.
    # "build(:user)" usa o FactoryBot para criar um User na MEMÓRIA (sem salvar no banco).
    # Isso torna os testes mais rápidos, pois evita acesso desnecessário ao banco.
    subject { build(:user) }

    # --------------------------------------------------
    # TESTE 1: Caminho feliz (Happy Path)
    # Garante que nossa factory está correta e que um User
    # com todos os dados válidos passa em todas as validações.
    # --------------------------------------------------
    it "is valid with valid attributes" do
      # "be_valid" verifica se o objeto não possui erros de validação
      expect(subject).to be_valid
    end

    # --------------------------------------------------
    # TESTE 2: Presença do e-mail
    # O Devise exige que o e-mail seja preenchido.
    # Testamos que um User sem e-mail é inválido.
    # --------------------------------------------------
    it "is not valid without an email" do
      subject.email = nil # Forçamos o e-mail a ser nulo
      expect(subject).to_not be_valid
    end

    # --------------------------------------------------
    # TESTE 3: Unicidade do e-mail
    # Dois usuários NÃO podem ter o mesmo e-mail.
    # "create" salva o primeiro usuário no banco de dados de teste.
    # "build" cria o segundo apenas na memória para testar a validação.
    # --------------------------------------------------
    it "is not valid with a duplicate email" do
      # Primeiro: criamos (e salvamos) um usuário com este e-mail
      create(:user, email: "duplicate@example.com")

      # Segundo: tentamos construir outro com o MESMO e-mail
      user = build(:user, email: "duplicate@example.com")

      # O segundo deve ser inválido por causa da unicidade
      expect(user).to_not be_valid
    end

    # --------------------------------------------------
    # TESTE 4: Presença da senha
    # O Devise exige uma senha para criar um usuário válido.
    # --------------------------------------------------
    it "is not valid without a password" do
      subject.password = nil
      expect(subject).to_not be_valid
    end

    # --------------------------------------------------
    # TESTE 5: Unicidade do username
    # A validação `validates :username, uniqueness: true` no modelo
    # garante que dois usuários não podem ter o mesmo nome de usuário.
    # --------------------------------------------------
    it "is not valid with a duplicate username" do
      # Cria e salva o primeiro usuário com este username
      create(:user, username: "testuser")

      # Tenta criar outro com o mesmo username
      user = build(:user, username: "testuser")

      # Deve falhar na validação de unicidade
      expect(user).to_not be_valid
    end
  end

  # --------------------------------------------------
  # Segundo grupo: Testamos as ASSOCIAÇÕES do modelo
  # --------------------------------------------------
  describe "associations" do

    # Verifica se a associação "has_many :posts" está definida no modelo.
    # Além disso, verificamos se o "dependent: :destroy" está configurado,
    # o que significa que ao deletar um User, todos os seus Posts são deletados também.
    it "has many posts" do
      association = described_class.reflect_on_association(:posts)

      # ".macro" retorna o tipo da associação (:belongs_to, :has_many, etc.)
      expect(association.macro).to eq(:has_many)

      # Verificamos a opção "dependent: :destroy" para garantir integridade dos dados
      expect(association.options[:dependent]).to eq(:destroy)
    end
  end

  # --------------------------------------------------
  # Terceiro grupo: Testamos os CALLBACKS do modelo
  # Callbacks são métodos chamados automaticamente em certos momentos
  # do ciclo de vida do objeto (ex: before_save, after_initialize)
  # --------------------------------------------------
  describe "callbacks" do

    # O modelo User tem um `after_initialize :set_default_role`
    # Isso significa que ao criar um novo User (mesmo sem salvar),
    # o campo "role" já deve vir preenchido como "basic".
    it "sets default role to basic after initialization or create" do
      # Ao criar via factory ou salvar, o callback deve adicionar a role
      user = create(:user)

      # Verificamos se o callback definiu o role corretamente via Rolify
      expect(user.has_role?(:basic)).to be true
    end
  end

  # --------------------------------------------------
  # Quarto grupo: Testamos o ENUM do modelo
  # Enums mapeiam strings (ou inteiros) do banco de dados para
  # constantes simbólicas no Ruby, tornando o código mais legível.
  # --------------------------------------------------
  describe "enums" do

    # O modelo define: enum :role, { basic: "basic", admin: "admin" }
    # Verificamos que os dois valores possíveis existem.
    it "allows assigning roles via Rolify" do
      user = create(:user)
      user.add_role(:admin)
      expect(user.has_role?(:admin)).to be true
    end
  end
end
