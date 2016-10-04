class CreateTwitterProfile < ActiveRecord::Migration
  def change
    create_table :twitter_profiles do |t|
      t.string :handle
      t.string :location
      t.string :bio
      t.datetime :member_since
      t.string :website
      t.integer :num_followers
      t.integer :num_following
      t.integer :num_tweets
      t.integer :num_favorites

      t.timestamps
    end
  end
end
