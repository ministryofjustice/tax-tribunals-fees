class AddConfirmationCodeToCaseRequest < ActiveRecord::Migration[5.0]
  def change
    add_column :case_requests, :confirmation_code, :string
  end
end
