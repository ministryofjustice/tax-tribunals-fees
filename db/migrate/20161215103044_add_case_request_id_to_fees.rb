class AddCaseRequestIdToFees < ActiveRecord::Migration[5.0]
  def change
    add_column :fees, :case_request_id, :uuid
  end
end
