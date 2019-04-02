class AddNewFieldsToSalesReceipts < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_receipts, :payment_received_date, :date unless column_exists? :sales_receipts, :payment_received_date
    add_column :sales_receipts, :payment_amount_received, :decimal unless column_exists? :sales_receipts, :payment_amount_received
    add_reference :sales_receipts, :currency unless column_exists? :sales_receipts, :currency_id
  end
end