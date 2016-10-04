class AddUniqueIndexOnTweetIdToTweets < ActiveRecord::Migration
  def change
    add_index :tweets, :tweet_id, unique: true
  end
end
