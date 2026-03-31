# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    if user.has_role?(:admin)
      can :manage, :all
      cannot :destroy, User, id: user.id
    else
      can :read, :all
      cannot :read, Post
      can :manage, Post, user_id: user.id
    end
  end
end
