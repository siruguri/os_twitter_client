class AddIndexOnTweetedAtToTweets < ActiveRecord::Migration
  def change
    add_index :tweets, :tweeted_at
  end
end
