class RemoveTwitterIdIndexesOnTweets < ActiveRecord::Migration
  def change
    remove_index :tweets, name: :index_tweets_on_twitter_id
    remove_index :tweets, name: :index_twitter_id_on_tweets
  end
end
