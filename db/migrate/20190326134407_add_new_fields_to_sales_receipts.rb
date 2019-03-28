class AddNewFieldsToSalesReceipts < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_receipts, :payment_received_date, :date
    add_column :sales_receipts, :payment_amount_received, :decimal
    add_reference :sales_receipts, :currency
  end
end