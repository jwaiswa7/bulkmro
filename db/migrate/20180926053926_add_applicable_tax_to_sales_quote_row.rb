class AddApplicableTaxToSalesQuoteRow < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_quote_rows, :legacy_applicable_tax, :string
    add_column :sales_quote_rows, :legacy_applicable_tax_class, :integer
  end
end
