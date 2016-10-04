class CreateAccountEntry < ActiveRecord::Migration
  def change
    create_table :account_entries do |t|
      t.float :entry_amount
      t.string :merchant_name
      t.datetime :entry_date

      t.timestamps
    end
  end
end
