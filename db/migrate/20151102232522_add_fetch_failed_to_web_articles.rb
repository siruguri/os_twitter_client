class AddFetchFailedToWebArticles < ActiveRecord::Migration
  def change
    add_column :web_articles, :fetch_failed, :boolean
  end
end
