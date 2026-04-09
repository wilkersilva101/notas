require 'rails_helper'

RSpec.describe ApplicationMailer, type: :mailer do
  describe "configuration" do
    it "has default from address" do
      expect(ApplicationMailer.default[:from]).to eq("from@example.com")
    end

    it "uses mailer layout" do
      expect(ApplicationMailer._layout).to eq("mailer")
    end
  end
end
