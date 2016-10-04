class AddUniqueIndexToWebArticle < ActiveRecord::Migration
  def change
    add_index :web_articles, :original_url, name: :index_original_url_on_web_articles, unique: true
  end
end
