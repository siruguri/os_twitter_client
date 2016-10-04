class AddLastTweetToTwitterProfile < ActiveRecord::Migration
  def change
    add_column :twitter_profiles, :last_tweet, :text
  end
end
