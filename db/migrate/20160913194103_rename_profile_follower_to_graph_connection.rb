class RenameProfileFollowerToGraphConnection < ActiveRecord::Migration
  def change
    rename_table :profile_followers, :graph_connections
  end
end
