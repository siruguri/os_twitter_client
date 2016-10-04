class CreateAccountEntriesTags < ActiveRecord::Migration
  def change
    create_table :account_entries_tags do |t|
      t.integer :transaction_tag_id
      t.integer :account_entry_id

      t.timestamps
    end
  end
end
