class ChangeForeignKeyInTweetPackets < ActiveRecord::Migration
  def up
    remove_column :tweet_packets, :handle
    add_column :tweet_packets, :twitter_id, :integer, limit: 8
  end

  def down
    add_column :tweet_packets, :handle, :string
    remove_column :tweet_packets, :twitter_id
  end
end
