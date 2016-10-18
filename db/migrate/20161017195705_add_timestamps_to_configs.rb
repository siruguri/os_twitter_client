class AddTimestampsToConfigs < ActiveRecord::Migration[5.0]
  def change
    add_column :configs, :created_at, :timestamp
    add_column :configs, :updated_at, :timestamp
  end
end
