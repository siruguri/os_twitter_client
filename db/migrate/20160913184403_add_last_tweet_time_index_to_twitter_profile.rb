class AddLastTweetTimeIndexToTwitterProfile < ActiveRecord::Migration
  def change
    add_index :twitter_profiles, :last_tweet_time
  end
end
