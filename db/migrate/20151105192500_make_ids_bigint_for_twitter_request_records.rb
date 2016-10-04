class MakeIdsBigintForTwitterRequestRecords < ActiveRecord::Migration
  def up
    change_column :twitter_request_records, :cursor, :bigint
  end

  def down
    change_column :twitter_request_records, :cursor, :integer
  end
end
