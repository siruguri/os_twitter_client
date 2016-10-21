class AddFollowerIdIndexToGraphConnection < ActiveRecord::Migration[5.0]
  def change
    add_index :graph_connections, :follower_id
  end
end
