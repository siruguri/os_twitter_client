class CreateMediaRecords < ActiveRecord::Migration
  def change
    create_table :media_records do |t|
      t.string :channel_id
      t.string :channel_name
      t.integer :channel_post_id

      t.timestamps
    end
  end
end
