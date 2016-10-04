class AddIsRetweetedToTweets < ActiveRecord::Migration
  def change
    add_column :tweets, :is_retweeted, :boolean
  end
end
