class AddFieldsToSalesReceipts < ActiveRecord::Migration[5.2]
  def change
    add_reference :sales_receipts, :sales_order, foreign_key: true
    add_column :sales_receipts, :payment_method, :integer, index: true
    add_column :sales_receipts, :payment_type, :integer, index: true
    remove_column :sales_receipts, :remote_uid, :integer
    add_column :sales_receipts, :remote_reference, :string
  end
end
