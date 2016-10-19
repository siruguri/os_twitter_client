class AddPreviousCursorToTwitterRequestRecord < ActiveRecord::Migration[5.0]
  def change
    add_column :twitter_request_records, :prev_cursor, :bigint
  end
end
