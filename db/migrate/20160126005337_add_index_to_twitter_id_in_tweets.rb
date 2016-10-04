class AddIndexToTwitterIdInTweets < ActiveRecord::Migration
  def change
    add_index :tweets, :twitter_id, name: :index_twitter_id_on_tweets
  end
end
