class AddAmountReceivedInSalesReceiptRows < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_receipt_rows, :amount_received, :decimal
  end
end
