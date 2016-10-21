class ModifyColumnTypeForGraphConnection < ActiveRecord::Migration[5.0]
  def change
    change_column :graph_connections, :follower_id, :bigint
    change_column :graph_connections, :leader_id, :bigint
  end
end
