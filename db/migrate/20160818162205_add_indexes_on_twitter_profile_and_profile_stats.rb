class AddIndexesOnTwitterProfileAndProfileStats < ActiveRecord::Migration
  def change
    add_index :profile_stats, :twitter_profile_id
    add_index :twitter_profiles, :twitter_id
  end
end
