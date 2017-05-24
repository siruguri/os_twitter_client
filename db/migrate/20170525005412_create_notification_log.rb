class CreateNotificationLog < ActiveRecord::Migration[5.0]
  def change
    create_table :notification_logs do |t|
      t.string :notification_message
      t.string :message_level
      t.timestamps
    end
  end
end

