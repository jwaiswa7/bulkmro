class AddCommentsToSalesReceipt < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_receipts, :comments, :text
  end
end