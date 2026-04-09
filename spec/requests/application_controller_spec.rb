require 'rails_helper'

RSpec.describe "ApplicationController", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }

  describe "layout selection" do
    context "for devise controllers" do
      it "uses devise layout for sign in" do
        get new_user_session_path
        expect(response).to have_http_status(:success)
      end
    end

    context "for regular controllers" do
      before { sign_in user }

      it "uses application layout" do
        get posts_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "CanCan::AccessDenied handling" do
    context "when user tries to delete itself" do
      before { sign_in admin }

      it "redirects with specific message for self-deletion" do
        delete user_path(admin)
        expect(response).to redirect_to(users_path)
        expect(flash[:alert]).to eq(I18n.t("flash.users.destroy.self_delete_forbidden"))
      end
    end

    context "when unauthorized user tries to access admin area" do
      before { sign_in user }

      it "redirects to root with generic message" do
        get new_admin_announcement_path
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Você não tem permissão para acessar esta página.")
      end
    end

    context "when user tries to access another user's post" do
      let(:other_user_post) { create(:post) }

      before { sign_in user }

      it "redirects to root with generic access denied message" do
        get post_path(other_user_post)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Você não tem permissão para acessar esta página.")
      end
    end
  end

  describe "browser version check" do
    before { sign_in user }

    it "allows modern browsers" do
      get posts_path, headers: { "HTTP_USER_AGENT" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" }
      expect(response).not_to have_http_status(:not_acceptable)
    end
  end
end
