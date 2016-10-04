class AddIndexToLeaderIdInProfileFollower < ActiveRecord::Migration
  def change
    add_index :profile_followers, :leader_id, name: :index_leader_id_on_profile_followers
  end
end
