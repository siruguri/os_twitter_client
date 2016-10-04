class ChangeJobIdTypeInJobRecords < ActiveRecord::Migration
  def change
    change_column :job_records, :job_id, :string
  end
end
