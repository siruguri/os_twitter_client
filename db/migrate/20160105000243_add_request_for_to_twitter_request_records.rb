class AddRequestForToTwitterRequestRecords < ActiveRecord::Migration
  def change
    add_column :twitter_request_records, :request_for, :string
  end
end
