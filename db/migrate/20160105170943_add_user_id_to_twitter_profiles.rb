class AddUserIdToTwitterProfiles < ActiveRecord::Migration
  def change
    add_column :twitter_profiles, :user_id, :integer
  end
end
