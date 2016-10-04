class AddJobNameToJobRecords < ActiveRecord::Migration
  def change
    add_column :job_records, :job_name, :string
  end
end
