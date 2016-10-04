class ChangeUpTweetPacketsToTweets < ActiveRecord::Migration
  def up
    remove_column :tweets, :tweets_list
    remove_column :tweets, :newest_tweet_at
    remove_column :tweets, :oldest_tweet_at
    remove_column :tweets, :max_id
    remove_column :tweets, :since_id

    add_column :tweets, :mesg, :text
    add_column :tweets, :tweet_id, :integer, limit: 8
  end

  def down
    add_column :tweets, :tweets_list, :text
    add_column :tweets, :newest_tweet_at, :datetime
    add_column :tweets, :oldest_tweet_at, :datetime
    add_column :tweets, :max_id, :integer, limit: 8
    add_column :tweets, :since_id, :integer, limit: 8

    remove_column :tweets, :mesg
    remove_column :tweets, :tweet_id
  end
end
