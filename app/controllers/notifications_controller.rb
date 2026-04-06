class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.order(created_at: :desc).page(params[:page]).per(10)
    @unread_ids = current_user.notifications.where(read: false).pluck(:id)
  end

  def mark_as_read
    @notification = current_user.notifications.find(params[:id])
    @notification.update(read: true)
    redirect_back fallback_location: notifications_path, notice: 'Notificação marcada como lida.'
  end

  def mark_all_as_read
    current_user.notifications.where(read: false).update_all(read: true)
    redirect_back fallback_location: notifications_path, notice: 'Todas as notificações marcadas como lidas.'
  end
end
