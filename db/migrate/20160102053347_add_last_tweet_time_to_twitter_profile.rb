class AddLastTweetTimeToTwitterProfile < ActiveRecord::Migration
  def change
    add_column :twitter_profiles, :last_tweet_time, :datetime
  end
end
