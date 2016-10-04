class AddRanLimitToTwitterRequestRecords < ActiveRecord::Migration
  def change
    add_column :twitter_request_records, :ran_limit, :boolean
  end
end
