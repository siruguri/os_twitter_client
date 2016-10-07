class AddTwitterProfileIdIndexToWebArticles < ActiveRecord::Migration[5.0]
  def change
    add_index :web_articles, :twitter_profile_id
  end
end
