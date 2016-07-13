class CreateCaseRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :case_requests, id: :uuid do |t|
      t.string :case_reference, null: false

      t.string :case_title, null: false
      t.integer :glimr_jurisdiction, null: false

      t.timestamps
    end
  end
end
