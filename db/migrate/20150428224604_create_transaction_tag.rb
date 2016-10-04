class CreateTransactionTag < ActiveRecord::Migration
  def change
    create_table :transaction_tags do |t|
      t.string :tag_name

      t.timestamps
    end
  end
end
