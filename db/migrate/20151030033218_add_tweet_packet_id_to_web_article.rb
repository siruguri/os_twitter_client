class AddTweetPacketIdToWebArticle < ActiveRecord::Migration
  def change
    add_column :web_articles, :tweet_packet_id, :integer
  end
end
