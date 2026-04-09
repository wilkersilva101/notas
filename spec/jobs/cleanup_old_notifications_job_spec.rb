require 'rails_helper'

RSpec.describe CleanupOldNotificationsJob, type: :job do
  describe "#perform" do
    let(:user) { create(:user) }

    it "deletes read notifications older than 30 days" do
      old_read_notification = create(:notification, user: user, read: true, created_at: 31.days.ago)
      recent_read_notification = create(:notification, user: user, read: true, created_at: 29.days.ago)
      old_unread_notification = create(:notification, user: user, read: false, created_at: 31.days.ago)

      expect {
        described_class.perform_now
      }.to change(Notification, :count).by(-1)

      expect(Notification.exists?(old_read_notification.id)).to be false
      expect(Notification.exists?(recent_read_notification.id)).to be true
      expect(Notification.exists?(old_unread_notification.id)).to be true
    end

    it "does not delete unread notifications regardless of age" do
      old_unread = create(:notification, user: user, read: false, created_at: 31.days.ago)
      recent_unread = create(:notification, user: user, read: false, created_at: 29.days.ago)

      expect {
        described_class.perform_now
      }.not_to change(Notification, :count)

      expect(Notification.exists?(old_unread.id)).to be true
      expect(Notification.exists?(recent_unread.id)).to be true
    end

    it "does not delete recent read notifications" do
      recent_read = create(:notification, user: user, read: true, created_at: 29.days.ago)

      expect {
        described_class.perform_now
      }.not_to change(Notification, :count)

      expect(Notification.exists?(recent_read.id)).to be true
    end
  end
end
