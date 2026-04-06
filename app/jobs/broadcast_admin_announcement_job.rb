class BroadcastAdminAnnouncementJob < ApplicationJob
  queue_as :default

  def perform(message)
    time_now = Time.current
    
    # Processamos os usuários em lotes de 1000 para evitar sobrecarga de memória (find_in_batches).
    # Em seguida, usamos o insert_all para realizar uma inserção em massa direto no banco.
    # O insert_all é consideravelmente mais rápido porque realiza uma única query de INSERT por lote
    # e ignora a instanciação de objetos ActiveRecord e os callbacks de validação.
    User.find_in_batches(batch_size: 1000) do |users|
      notifications = users.map do |user|
        {
          user_id: user.id,
          message: message,
          read: false,
          created_at: time_now,
          updated_at: time_now
        }
      end

      Notification.insert_all(notifications) unless notifications.empty?
    end
  end
end
