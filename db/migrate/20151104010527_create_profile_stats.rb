class CreateProfileStats < ActiveRecord::Migration
  def change
    create_table :profile_stats do |t|
      t.text :stats_hash
      t.integer :twitter_profile_id
    end
  end
end
