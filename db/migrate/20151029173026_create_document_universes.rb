class CreateDocumentUniverses < ActiveRecord::Migration
  def change
    create_table :document_universes do |t|
      t.text :universe

      t.timestamps
    end
  end
end
