class RemoveStatsHashFromProfileStats < ActiveRecord::Migration
  def up
    remove_column :profile_stats, :stats_hash
  end
  
  def down
    add_column :profile_stats, :stats_hash, :text
  end
end
