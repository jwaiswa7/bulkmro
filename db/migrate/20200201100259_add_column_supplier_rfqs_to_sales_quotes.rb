class AddColumnSupplierRfqsToSalesQuotes < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_quotes, :supplier_rfq_ids, :string, array: true, default: []
  end
end
