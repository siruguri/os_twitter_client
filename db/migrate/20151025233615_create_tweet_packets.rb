class CreateTweetPackets < ActiveRecord::Migration
  def change
    create_table :tweet_packets do |t|
      t.text :tweets_list
      t.datetime :newest_tweet_at
      t.datetime :oldest_tweet_at
      t.integer :max_id
      t.integer :since_id
      t.string :handle

      t.timestamps
    end
  end
end
