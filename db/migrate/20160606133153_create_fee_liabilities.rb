class CreateFeeLiabilities < ActiveRecord::Migration[5.0]
  def change
    create_table :fee_liabilities, id: :uuid do |t|
      t.uuid :case_request_id

      t.string :description
      t.integer :amount
      t.integer :glimr_id

      t.timestamps
    end
  end
end
