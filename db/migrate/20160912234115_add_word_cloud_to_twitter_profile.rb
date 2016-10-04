class AddWordCloudToTwitterProfile < ActiveRecord::Migration
  def change
    add_column :twitter_profiles, :word_cloud, :text
  end
end
