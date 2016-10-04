class CreateCreateChannelPosts < ActiveRecord::Migration
  def change
    create_table :create_channel_posts do |t|
      t.string :url
      t.text :message
      t.string :tweet_tags
      t.string :short_message
      t.datetime :last_posted_at
      t.string :redirect_url
      t.integer :total_post_count
      t.integer :post_strategy
      t.boolean :post_again

      t.timestamps null: false
    end
  end
end
