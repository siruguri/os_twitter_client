class AddUserIdIndexToTwitterProfileUniq < ActiveRecord::Migration
  def change
    add_index :twitter_profiles, :user_id, unique: true
  end
end
