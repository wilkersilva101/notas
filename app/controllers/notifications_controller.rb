class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.order(created_at: :desc).page(params[:page]).per(10)
    @unread_ids = current_user.notifications.where(read: false).pluck(:id)
    current_user.notifications.where(id: @unread_ids).update_all(read: true) if @unread_ids.any?
  end
end
