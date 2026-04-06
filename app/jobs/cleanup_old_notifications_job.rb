class CleanupOldNotificationsJob < ApplicationJob
  queue_as :default

  def perform
    # Deleta as notificações lidas que são mais antigas que 30 dias
    Notification.where(read: true).where("created_at < ?", 30.days.ago).delete_all
  end
end
