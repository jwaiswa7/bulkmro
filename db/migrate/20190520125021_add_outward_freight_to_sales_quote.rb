class AddOutwardFreightToSalesQuote < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_quotes, :outward_freight, :decimal
    add_column :sales_quotes, :outward_freight_scope, :integer
  end
end
