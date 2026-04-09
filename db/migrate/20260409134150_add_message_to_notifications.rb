class AddMessageToNotifications < ActiveRecord::Migration[8.0]
  def change
    add_column :notifications, :message, :text
  end
end
