class AddStatusMessageToTwitterRequestRecord < ActiveRecord::Migration
  def change
    add_column :twitter_request_records, :status_message, :string
  end
end
