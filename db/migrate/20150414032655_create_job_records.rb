class CreateJobRecords < ActiveRecord::Migration
  def change
    create_table :job_records do |t|
      t.integer :job_id
      t.string :status

      t.timestamps
    end
  end
end
