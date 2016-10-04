class RenameCreateChannelPostsToChannelPosts < ActiveRecord::Migration
  def change
    rename_table :create_channel_posts, :channel_posts
  end
end
