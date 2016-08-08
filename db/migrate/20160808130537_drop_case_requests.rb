class DropCaseRequests < ActiveRecord::Migration[5.0]
  def change
    drop_table :case_requests
  end
end
