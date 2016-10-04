class CreateChannelPostRedirectMaps < ActiveRecord::Migration
  def change
    create_table :channel_post_redirect_maps do |t|
      t.integer :channel_post_id
      t.integer :redirect_map_id

      t.timestamps
    end
  end
end
