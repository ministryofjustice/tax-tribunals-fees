class AddPayByAccountReferencesToFees < ActiveRecord::Migration[5.0]
  def change
    add_column :fees, :pay_by_account_reference, :string
    add_column :fees, :pay_by_account_confirmation, :string
    add_column :fees, :pay_by_account_transaction_reference, :string
  end
end
