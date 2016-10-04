class AddAuthorAndOriginalUrlToWebArticles < ActiveRecord::Migration
  def change
    add_column :web_articles, :author, :string
    add_column :web_articles, :original_url, :string
  end
end
