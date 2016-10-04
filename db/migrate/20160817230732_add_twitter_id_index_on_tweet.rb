class AddTwitterIdIndexOnTweet < ActiveRecord::Migration
  def change
    add_index :tweets, :twitter_id
  end
end
