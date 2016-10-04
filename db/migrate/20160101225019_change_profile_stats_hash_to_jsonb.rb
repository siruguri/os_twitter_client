class ChangeProfileStatsHashToJsonb < ActiveRecord::Migration
  def up
    enable_extension 'citext'   
    add_column :profile_stats, :stats_hash_v2, :jsonb, null: false, default: '{}'
  end
  
  def down
    disable_extension 'citext'   
    remove_column :profile_stats, :stats_hash_v2
  end
end
