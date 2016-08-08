class RenameFeeLiabilitiesToLiabilities < ActiveRecord::Migration[5.0]
  def change
    rename_table :fee_liabilities, :liabilities
  end
end
