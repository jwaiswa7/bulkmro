class AddReconciledAmountToSalesReceipt < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_receipts, :reconciled_amount, :decimal
  end
end
