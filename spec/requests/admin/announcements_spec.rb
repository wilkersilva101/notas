require 'rails_helper'

RSpec.describe "Admin::Announcements", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin) { create(:user, :admin) }
  let(:user) { create(:user) }

  describe "GET /admin/announcements/new" do
    context "as admin" do
      before { sign_in admin }

      it "returns a successful response" do
        get new_admin_announcement_path
        expect(response).to have_http_status(:success)
      end
    end

    context "as regular user" do
      before { sign_in user }

      it "redirects to root with alert" do
        get new_admin_announcement_path
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Você não tem permissão para acessar esta página.")
      end
    end

    context "as guest" do
      it "redirects to sign in" do
        get new_admin_announcement_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST /admin/announcements" do
    context "as admin" do
      before { sign_in admin }

      context "with valid message" do
        let(:valid_params) { { message: "System maintenance scheduled" } }

        it "enqueues BroadcastAdminAnnouncementJob" do
          expect {
            post admin_announcements_path, params: valid_params
          }.to have_enqueued_job(BroadcastAdminAnnouncementJob).with("System maintenance scheduled")
        end

        it "redirects to new announcement path with notice" do
          post admin_announcements_path, params: valid_params
          expect(response).to redirect_to(new_admin_announcement_path)
          expect(flash[:notice]).to include("Aviso em processamento")
        end
      end

      context "with blank message" do
        it "redirects with alert" do
          post admin_announcements_path, params: { message: "" }
          expect(response).to redirect_to(new_admin_announcement_path)
          expect(flash[:alert]).to eq("A mensagem do aviso não pode estar vazia.")
        end

        it "does not enqueue job" do
          expect {
            post admin_announcements_path, params: { message: "" }
          }.not_to have_enqueued_job(BroadcastAdminAnnouncementJob)
        end
      end
    end

    context "as regular user" do
      before { sign_in user }

      it "redirects to root with alert" do
        post admin_announcements_path, params: { message: "Test" }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Você não tem permissão para acessar esta página.")
      end
    end
  end
end
