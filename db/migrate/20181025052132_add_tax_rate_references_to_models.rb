class AddTaxRateReferencesToModels < ActiveRecord::Migration[5.2]
  def change
    add_reference :categories, :tax_rate, foreign_key: true
    add_reference :products, :tax_rate, foreign_key: true
    add_reference :sales_quote_rows, :tax_rate, foreign_key: true
  end
end