class AddTimestampsToProfileStat < ActiveRecord::Migration
  def change
    add_column :profile_stats, :most_recent_tweet_at, :datetime
    add_column :profile_stats, :most_old_tweet_at, :datetime
  end
end
