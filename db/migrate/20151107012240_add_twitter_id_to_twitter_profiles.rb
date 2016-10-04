class AddTwitterIdToTwitterProfiles < ActiveRecord::Migration
  def change
    add_column :twitter_profiles, :twitter_id, :bigint
  end
end
