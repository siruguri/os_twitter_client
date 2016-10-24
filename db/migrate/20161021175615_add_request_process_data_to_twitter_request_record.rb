class AddRequestProcessDataToTwitterRequestRecord < ActiveRecord::Migration[5.0]
  def change
    add_column :twitter_request_records, :request_process_data, :jsonb
  end
end
