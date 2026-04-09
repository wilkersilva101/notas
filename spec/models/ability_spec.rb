require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do
  describe "admin user" do
    let(:admin) { create(:user, :admin) }
    let(:ability) { Ability.new(admin) }

    it "can manage all resources" do
      expect(ability).to be_able_to(:manage, :all)
    end

    it "cannot destroy itself" do
      expect(ability).not_to be_able_to(:destroy, admin)
    end

    it "can destroy other users" do
      other_user = create(:user)
      expect(ability).to be_able_to(:destroy, other_user)
    end
  end

  describe "basic user" do
    let(:user) { create(:user) }
    let(:ability) { Ability.new(user) }
    let(:own_post) { create(:post, user: user) }
    let(:other_user_post) { create(:post) }

    it "cannot manage all resources" do
      expect(ability).not_to be_able_to(:manage, :all)
    end

    it "can read all except posts" do
      expect(ability).to be_able_to(:read, User)
      expect(ability).not_to be_able_to(:read, other_user_post)
    end

    it "can manage own posts" do
      expect(ability).to be_able_to(:manage, own_post)
    end

    it "cannot manage other users posts" do
      expect(ability).not_to be_able_to(:manage, other_user_post)
    end

    it "can read own posts" do
      expect(ability).to be_able_to(:read, own_post)
    end

    it "cannot read other users posts" do
      expect(ability).not_to be_able_to(:read, other_user_post)
    end
  end

  describe "guest user (nil)" do
    let(:ability) { Ability.new(nil) }

    it "cannot access anything" do
      expect(ability).not_to be_able_to(:read, Post)
      expect(ability).not_to be_able_to(:manage, :all)
    end
  end
end
