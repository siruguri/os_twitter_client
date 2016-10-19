class AddTimestampsToGraphConnections < ActiveRecord::Migration[5.0]
  def change
    add_column :graph_connections, :created_at, :datetime
    add_column :graph_connections, :updated_at, :datetime
  end
end
