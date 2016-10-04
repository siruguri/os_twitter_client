class ChangeTweetPacketTableName < ActiveRecord::Migration
  def up
    rename_table :tweet_packets, :tweets
  end

  def down
    rename_table :tweets, :tweet_packets
  end
end
