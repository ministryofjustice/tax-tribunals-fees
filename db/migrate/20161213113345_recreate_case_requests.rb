class RecreateCaseRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :case_requests, id: :uuid do |t|
      t.string :case_reference, null: false
      t.string :confirmation_code, null: false

      t.timestamps
    end
  end
end
