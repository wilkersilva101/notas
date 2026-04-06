require 'rails_helper'

RSpec.describe BroadcastAdminAnnouncementJob, type: :job do
  describe "#perform" do
    before do
      # Cria 5 usuários no banco para o teste usando a factory do User
      create_list(:user, 5)
    end

    it "creates a notification for each user in the database efficiently" do
      message = "O sistema entrará em manutenção amanhã."

      expect {
        described_class.perform_now(message)
      }.to change(Notification, :count).by(5)

      # Validar se as mensagens criadas estão corretas para todos
      expect(Notification.where(message: message).count).to eq(5)
      expect(Notification.where(read: false).count).to eq(5)
      expect(Notification.pluck(:user_id).sort).to eq(User.pluck(:id).sort)
    end
  end
end
