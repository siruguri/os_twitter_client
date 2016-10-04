class CreateArticleTaggings < ActiveRecord::Migration
  def change
    create_table :article_taggings do |t|
      t.integer :article_tag_id
      t.integer :web_article_id

      t.timestamps
    end
  end
end
