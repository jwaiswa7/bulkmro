class AddColumnUomToSalesQuoteRow < ActiveRecord::Migration[5.2]
  def change
    add_reference :sales_quote_rows, :measurement_unit, foreign_key: true
  end
end
