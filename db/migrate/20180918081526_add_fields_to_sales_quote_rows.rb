class AddFieldsToSalesQuoteRows < ActiveRecord::Migration[5.2]
  def change
    add_reference :sales_quote_rows, :lead_time, foreign_key: true
  end
end
