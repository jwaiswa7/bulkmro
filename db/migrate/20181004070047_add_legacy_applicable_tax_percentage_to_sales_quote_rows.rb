class AddLegacyApplicableTaxPercentageToSalesQuoteRows < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_quote_rows, :legacy_applicable_tax_percentage, :decimal
  end
end
