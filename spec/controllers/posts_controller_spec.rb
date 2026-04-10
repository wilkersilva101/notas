# Controller spec com shoulda-matchers funcionais
# NOTA: Alguns matchers foram removidos do shoulda-matchers nas versões recentes
# Por isso usamos uma mistura de matchers + assertions tradicionais

require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:post_record) { create(:post, user: user) }

  before { sign_in user }

  # ============================================
  # MATCHERS DE FILTROS (funcionam com callbacks padrão)
  # ============================================
  describe 'filters' do
    it { should use_before_action(:authenticate_user!) }

    # load_and_authorize_resource do CanCanCan não é detectado
    # porque vem de uma gem externa, testamos de outra forma abaixo
  end

  # ============================================
  # MATCHERS DE ROTA (shoulda-matchers)
  # ============================================
  describe 'routing' do
    it { should route(:get, '/posts').to(action: :index) }
    it { should route(:get, '/posts/1').to(action: :show, id: 1) }
    it { should route(:get, '/posts/new').to(action: :new) }
    it { should route(:get, '/posts/1/edit').to(action: :edit, id: 1) }
    it { should route(:post, '/posts').to(action: :create) }
    it { should route(:patch, '/posts/1').to(action: :update, id: 1) }
    it { should route(:delete, '/posts/1').to(action: :destroy, id: 1) }
  end

  # ============================================
  # GET #index
  # ============================================
  describe 'GET #index' do
    before { get :index }

    # Matcher shoulda: status HTTP
    it { should respond_with(:success) }

    # Assertions tradicionais (render_template precisa da gem rails-controller-testing)
    it 'renders the index template' do
      expect(response).to render_template(:index)
    end

    it 'assigns @posts' do
      expect(assigns(:posts)).to be_a(ActiveRecord::Relation)
    end
  end

  # ============================================
  # GET #show
  # ============================================
  describe 'GET #show' do
    before { get :show, params: { id: post_record.id } }

    it { should respond_with(:success) }

    it 'renders the show template' do
      expect(response).to render_template(:show)
    end

    it 'assigns the requested post to @post' do
      expect(assigns(:post)).to eq(post_record)
    end
  end

  # ============================================
  # GET #new
  # ============================================
  describe 'GET #new' do
    before { get :new }

    it { should respond_with(:success) }

    it 'renders the new template' do
      expect(response).to render_template(:new)
    end

    it 'assigns a new post to @post' do
      expect(assigns(:post)).to be_a_new(Post)
    end
  end

  # ============================================
  # GET #edit
  # ============================================
  describe 'GET #edit' do
    before { get :edit, params: { id: post_record.id } }

    it { should respond_with(:success) }

    it 'renders the edit template' do
      expect(response).to render_template(:edit)
    end

    it 'assigns the requested post to @post' do
      expect(assigns(:post)).to eq(post_record)
    end
  end

  # ============================================
  # POST #create
  # ============================================
  describe 'POST #create' do
    context 'com parâmetros válidos' do
      let(:valid_params) { { post: { titulo: 'New Post', descricao: 'Description' } } }

      it 'cria um novo post' do
        expect {
          post :create, params: valid_params
        }.to change(Post, :count).by(1)
      end

      it 'redireciona para o post criado' do
        post :create, params: valid_params
        expect(response).to redirect_to(post_path(Post.last))
      end

      it 'seta flash notice' do
        post :create, params: valid_params
        expect(flash[:notice]).to match(/Nota.*criada/i)
      end
    end

    context 'com parâmetros inválidos' do
      let(:invalid_params) { { post: { titulo: '', descricao: '' } } }

      before { post :create, params: invalid_params }

      # Rack 3 usa :unprocessable_content em vez de :unprocessable_entity
      it { should respond_with(:unprocessable_content) }

      it 're-renders the new template' do
        expect(response).to render_template(:new)
      end
    end
  end

  # ============================================
  # PATCH #update
  # ============================================
  describe 'PATCH #update' do
    context 'com parâmetros válidos' do
      let(:new_params) { { id: post_record.id, post: { titulo: 'Updated' } } }

      before { patch :update, params: new_params }

      it { should redirect_to(post_path(post_record)) }

      it 'seta flash notice' do
        expect(flash[:notice]).to match(/Nota.*atualizada/i)
      end
    end

    context 'quando admin atualiza post de outro usuário' do
      let(:other_user) { create(:user) }
      let(:other_post) { create(:post, user: other_user) }

      before { sign_in admin }

      it 'cria notificação para o dono do post' do
        expect {
          patch :update, params: { id: other_post.id, post: { titulo: 'Admin Updated' } }
        }.to change(Notification, :count).by(1)

        notification = Notification.last
        expect(notification.user).to eq(other_user)
        expect(notification.message).to include('Admin alterou o seu post')
      end
    end
  end

  # ============================================
  # DELETE #destroy
  # ============================================
  describe 'DELETE #destroy' do
    let!(:post_to_delete) { create(:post, user: user) }

    it 'deleta o post' do
      expect {
        delete :destroy, params: { id: post_to_delete.id }
      }.to change(Post, :count).by(-1)
    end

    it 'redireciona para posts_path' do
      delete :destroy, params: { id: post_to_delete.id }
      expect(response).to redirect_to(posts_path)
    end

    context 'quando admin deleta post de outro usuário' do
      let(:other_user) { create(:user) }
      let(:other_post) { create(:post, user: other_user) }

      before { sign_in admin }

      it 'cria notificação para o dono' do
        expect {
          delete :destroy, params: { id: other_post.id }
        }.to change(Notification, :count).by(1)

        notification = Notification.last
        expect(notification.user).to eq(other_user)
        expect(notification.message).to include('Admin excluiu o seu post')
      end
    end
  end

  # ============================================
  # Teste de autorização (CanCanCan)
  # ============================================
  describe 'authorization' do
    let(:other_user) { create(:user) }
    # let! cria imediatamente (eager), não lazy
    let!(:other_post) { create(:post, user: other_user) }

    context 'quando usuário tenta acessar post de outro' do
      before { sign_in user }

      it 'redireciona ao tentar editar post de outro usuário' do
        get :edit, params: { id: other_post.id }
        # CanCanCan redireciona para root ou página anterior quando não autorizado
        expect(response).to redirect_to(root_path)
      end

      it 'redireciona ao tentar atualizar post de outro usuário' do
        patch :update, params: { id: other_post.id, post: { titulo: 'Hacked' } }
        expect(response).to redirect_to(root_path)
      end

      it 'redireciona ao tentar deletar post de outro usuário' do
        delete :destroy, params: { id: other_post.id }
        expect(response).to redirect_to(root_path)
      end

      it 'não altera o post de outro usuário' do
        original_title = other_post.titulo
        patch :update, params: { id: other_post.id, post: { titulo: 'Hacked' } }
        other_post.reload
        expect(other_post.titulo).to eq(original_title)
      end

      it 'não deleta o post de outro usuário' do
        expect {
          delete :destroy, params: { id: other_post.id }
        }.not_to change(Post, :count)
      end
    end
  end
end
