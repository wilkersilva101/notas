require 'rails_helper'

RSpec.describe "Users", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin) { create(:user, :admin) }
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe "GET /users" do
    context "as admin" do
      before { sign_in admin }

      it "returns a successful response" do
        get users_path
        expect(response).to have_http_status(:success)
      end
    end

    context "as regular user" do
      before { sign_in user }

      it "returns a successful response" do
        get users_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /users/:id" do
    before { sign_in admin }

    it "returns a successful response" do
      get user_path(user)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /users/:id/edit" do
    context "as admin" do
      before { sign_in admin }

      it "returns a successful response" do
        get edit_user_path(user)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PATCH /users/:id" do
    context "as admin" do
      before { sign_in admin }

      context "with valid parameters" do
        it "updates the user" do
          patch user_path(user), params: { user: { email: "newemail@example.com" } }
          expect(user.reload.email).to eq("newemail@example.com")
        end

        it "redirects to users index" do
          patch user_path(user), params: { user: { email: "newemail@example.com" } }
          expect(response).to redirect_to(users_path)
        end
      end

      context "with blank password" do
        it "updates user without changing password" do
          original_encrypted_password = user.encrypted_password
          patch user_path(user), params: { user: { email: "new@example.com", password: "", password_confirmation: "" } }
          expect(user.reload.encrypted_password).to eq(original_encrypted_password)
        end
      end

      context "with invalid parameters" do
        it "returns unprocessable entity status" do
          patch user_path(user), params: { user: { email: "" } }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe "DELETE /users/:id" do
    context "as admin" do
      before { sign_in admin }

      it "destroys the user" do
        user_to_delete = create(:user)
        user_to_delete.roles.destroy_all
        expect {
          delete user_path(user_to_delete)
        }.to change(User, :count).by(-1)
      end

      it "redirects to users index" do
        user_to_delete = create(:user)
        user_to_delete.roles.destroy_all
        delete user_path(user_to_delete)
        expect(response).to redirect_to(users_path)
      end
    end

    context "when admin tries to destroy itself" do
      before { sign_in admin }

      it "redirects with alert" do
        delete user_path(admin)
        expect(response).to redirect_to(users_path)
        expect(flash[:alert]).to eq(I18n.t("flash.users.destroy.self_delete_forbidden"))
      end

      it "does not destroy itself" do
        expect {
          delete user_path(admin)
        }.not_to change(User, :count)
      end
    end
  end
end
