class ChangeTweetPacketIdToTweetIdInWebArticle < ActiveRecord::Migration
  def change
    rename_column :web_articles, :tweet_packet_id, :tweet_id
  end
end
