class AddUserIdToNotificationLog < ActiveRecord::Migration[5.0]
  def change
    add_column :notification_logs, :user_id, :integer
  end
end
