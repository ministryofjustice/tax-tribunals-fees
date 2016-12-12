class AddHelpWithFeesReferenceToFees < ActiveRecord::Migration[5.0]
  def change
    add_column :fees, :help_with_fees_reference, :string
  end
end
