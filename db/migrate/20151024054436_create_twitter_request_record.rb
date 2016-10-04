class CreateTwitterRequestRecord < ActiveRecord::Migration
  def change
    create_table :twitter_request_records do |t|
      t.string :handle
      t.integer :cursor
      t.string :request_type
      t.boolean :status

      t.timestamps
    end
  end
end
