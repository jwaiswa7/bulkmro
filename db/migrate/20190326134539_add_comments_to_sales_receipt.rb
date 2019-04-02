class AddCommentsToSalesReceipt < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_receipts, :comments, :text unless column_exists? :sales_receipts, :comments
  end
end