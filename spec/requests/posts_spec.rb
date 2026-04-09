require 'rails_helper'

RSpec.describe "Posts", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:other_user) { create(:user) }
  let!(:post1) { create(:post, user: user, titulo: "User Post") }

  describe "GET /posts" do
    before { sign_in user }

    it "returns a successful response" do
      get posts_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /posts/:id" do
    before { sign_in user }

    it "returns a successful response for own post" do
      get post_path(post1)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /posts/new" do
    before { sign_in user }

    it "returns a successful response" do
      get new_post_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /posts/:id/edit" do
    before { sign_in user }

    it "returns a successful response for own post" do
      get edit_post_path(post1)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /posts" do
    before { sign_in user }

    context "with valid parameters" do
      let(:valid_params) { { post: { titulo: "New Post", descricao: "Description" } } }

      it "creates a new post" do
        expect {
          post posts_path, params: valid_params
        }.to change(Post, :count).by(1)
      end

      it "redirects to the created post" do
        post posts_path, params: valid_params
        expect(response).to redirect_to(post_path(Post.last))
      end

      it "returns JSON response when requested" do
        post posts_path, params: valid_params, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq("application/json; charset=utf-8")
        json_response = JSON.parse(response.body)
        expect(json_response["titulo"]).to eq("New Post")
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { { post: { titulo: "", descricao: "" } } }

      it "does not create a new post" do
        expect {
          post posts_path, params: invalid_params
        }.not_to change(Post, :count)
      end

      it "returns unprocessable entity status" do
        post posts_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns JSON error response when requested" do
        post posts_path, params: invalid_params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq("application/json; charset=utf-8")
      end
    end
  end

  describe "PATCH /posts/:id" do
    before { sign_in user }

    context "with valid parameters" do
      let(:new_params) { { post: { titulo: "Updated Title" } } }

      it "updates the post" do
        patch post_path(post1), params: new_params
        expect(post1.reload.titulo).to eq("Updated Title")
      end

      it "redirects to the post" do
        patch post_path(post1), params: new_params
        expect(response).to redirect_to(post_path(post1))
      end

      it "returns JSON response when requested" do
        patch post_path(post1), params: new_params, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("application/json; charset=utf-8")
        json_response = JSON.parse(response.body)
        expect(json_response["titulo"]).to eq("Updated Title")
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { { post: { titulo: "" } } }

      it "returns JSON error response when requested" do
        patch post_path(post1), params: invalid_params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq("application/json; charset=utf-8")
      end
    end

    context "when admin updates other user's post" do
      let(:other_post) { create(:post, user: other_user, titulo: "Original Title") }

      before { sign_in admin }

      it "creates a notification for the post owner" do
        expect {
          patch post_path(other_post), params: { post: { titulo: "Admin Updated" } }
        }.to change(Notification, :count).by(1)

        notification = Notification.last
        expect(notification.user).to eq(other_user)
        expect(notification.message).to include("Admin alterou o seu post")
      end
    end
  end

  describe "DELETE /posts/:id" do
    before { sign_in user }

    it "destroys the post" do
      expect {
        delete post_path(post1)
      }.to change(Post, :count).by(-1)
    end

    it "redirects to posts index" do
      delete post_path(post1)
      expect(response).to redirect_to(posts_path)
    end

    it "returns JSON response when requested" do
      delete post_path(post1), as: :json
      expect(response).to have_http_status(:no_content)
    end

    context "when admin destroys other user's post" do
      let(:other_post) { create(:post, user: other_user, titulo: "Post to Delete") }

      before { sign_in admin }

      it "creates a notification for the post owner" do
        expect {
          delete post_path(other_post)
        }.to change(Notification, :count).by(1)

        notification = Notification.last
        expect(notification.user).to eq(other_user)
        expect(notification.message).to include("Admin excluiu o seu post")
      end
    end
  end
end
