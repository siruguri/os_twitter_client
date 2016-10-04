class CreateProfileFollowers < ActiveRecord::Migration
  def change
    create_table :profile_followers do |t|
      t.integer :leader_id
      t.integer :follower_id
    end
  end
end
