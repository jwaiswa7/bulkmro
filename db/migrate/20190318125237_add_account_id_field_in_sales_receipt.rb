class AddAccountIdFieldInSalesReceipt < ActiveRecord::Migration[5.2]
  def change
    # remove_column :sales_receipts, :account_id, :integer
    add_reference :sales_receipts,:account, foreign_key: true
  end
end
