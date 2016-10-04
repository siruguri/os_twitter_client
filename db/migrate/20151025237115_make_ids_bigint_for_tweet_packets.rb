class MakeIdsBigintForTweetPackets < ActiveRecord::Migration
  def up
    change_column :tweet_packets, :max_id, :bigint
    change_column :tweet_packets, :since_id, :bigint
  end

  def down
    change_column :tweet_packets, :max_id, :integer
    change_column :tweet_packets, :since_id, :integer
  end
end
