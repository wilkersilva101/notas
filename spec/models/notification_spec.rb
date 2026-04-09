require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe "associations" do
    it "belongs to a user" do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq(:belongs_to)
    end
  end

  describe "callbacks" do
    describe "#set_default_read" do
      it "sets read to false by default for new records" do
        notification = Notification.new(message: "Test message", user: create(:user))
        expect(notification.read).to be false
      end

      it "does not override read if already set" do
        notification = Notification.new(message: "Test", user: create(:user), read: true)
        expect(notification.read).to be true
      end
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      notification = build(:notification)
      expect(notification).to be_valid
    end

    it "is not valid without a user" do
      notification = build(:notification, user: nil)
      expect(notification).not_to be_valid
    end
  end
end
