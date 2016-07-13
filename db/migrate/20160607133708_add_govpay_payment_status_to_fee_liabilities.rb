class AddGovpayPaymentStatusToFeeLiabilities < ActiveRecord::Migration[5.0]
  def change
    add_column :fee_liabilities, :govpay_payment_status, :string
    add_column :fee_liabilities, :govpay_payment_message, :string
  end
end
