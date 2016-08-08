class DropFeeLiabilitesCreateFees < ActiveRecord::Migration[5.0]
  def change
    create_table :fees, id: :uuid do |t|
      t.string :case_reference, index: true
      t.string :confirmation_code_digest
      t.string :description
      t.integer :amount
      t.integer :glimr_id
      t.string :govpay_payment_status
      t.string :govpay_payment_message
      t.string :govpay_reference
      t.string :govpay_payment_id
      t.timestamps
    end

    drop_table :liabilities
  end
end
