class AddAccountIdFieldInSalesReceipt < ActiveRecord::Migration[5.2]
  def change
    add_reference :sales_receipts,:account,foreign_key: true unless column_exists? :sales_receipts,:account_id
  end
end
