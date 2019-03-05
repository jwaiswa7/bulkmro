class AddAccountIdFieldInSalesReceipt < ActiveRecord::Migration[5.2]
  def change
    add_reference :sales_receipts,:account,foreign_key: true
  end
end
