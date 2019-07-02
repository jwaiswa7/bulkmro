class AddInwardFreightToSalesQuoteRows < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_quote_rows, :inward_freight, :decimal
    add_column :sales_quote_rows, :inward_freight_scope, :integer
  end
end
