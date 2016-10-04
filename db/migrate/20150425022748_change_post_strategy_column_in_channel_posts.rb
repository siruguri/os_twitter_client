class ChangePostStrategyColumnInChannelPosts < ActiveRecord::Migration
  def change
    change_column :channel_posts, :post_strategy, :string
  end
end
