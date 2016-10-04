class AddIndexToStatsHashV2 < ActiveRecord::Migration
  def change
    add_index :profile_stats, :stats_hash_v2, using: :gin
  end
end
