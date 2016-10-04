class AddTweetDetailsToTweets < ActiveRecord::Migration
  def up
    add_column :tweets, :tweet_details, :jsonb, null: false, default: {}
  end

  def down
    remove_column :tweets, :tweet_details
  end  
end
