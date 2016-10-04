class ChangeTweetIdToTwitterProfileIdInWebArticle < ActiveRecord::Migration
  def change
    rename_column :web_articles, :tweet_id, :twitter_profile_id
  end
end
