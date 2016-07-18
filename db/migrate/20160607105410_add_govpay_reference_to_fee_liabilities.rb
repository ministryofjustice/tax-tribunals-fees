class AddGovpayReferenceToFeeLiabilities < ActiveRecord::Migration[5.0]
  def change
    add_column :fee_liabilities, :govpay_reference, :string
    add_column :fee_liabilities, :govpay_payment_id, :string
  end
end
