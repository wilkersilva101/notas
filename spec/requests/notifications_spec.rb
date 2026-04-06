require 'rails_helper'

RSpec.describe "Notifications", type: :request do
  include Devise::Test::IntegrationHelpers
  let(:user) { create(:user) }
  let!(:notification1) { create(:notification, user: user, read: false) }
  let!(:notification2) { create(:notification, user: user, read: false) }

  before do
    sign_in user
  end

  describe "GET /notifications" do
    it "renders the index page successfully" do
      get notifications_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Suas Notificações")
    end

    it "does NOT mark notifications as read automatically" do
      expect {
        get notifications_path
      }.not_to change { notification1.reload.read }.from(false)
      
      expect(notification2.reload.read).to be false
    end
  end

  describe "PATCH /notifications/:id/mark_as_read" do
    it "marks a single notification as read" do
      patch mark_as_read_notification_path(notification1)
      expect(notification1.reload.read).to be true
      expect(notification2.reload.read).to be false
      expect(response).to redirect_to(notifications_path)
      expect(flash[:notice]).to eq('Notificação marcada como lida.')
    end
  end

  describe "PATCH /notifications/mark_all_as_read" do
    it "marks all notifications of the user as read" do
      patch mark_all_as_read_notifications_path
      expect(notification1.reload.read).to be true
      expect(notification2.reload.read).to be true
      expect(response).to redirect_to(notifications_path)
      expect(flash[:notice]).to eq('Todas as notificações marcadas como lidas.')
    end
  end
end
