class CreateChannelSecrets < ActiveRecord::Migration
  def change
    create_table :channel_secrets do |t|
      t.integer :user_id
      t.string :secret_for
      t.text :secrets_hash

      t.timestamps
    end
  end
end
