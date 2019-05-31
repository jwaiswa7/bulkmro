class AddCreditNoteFieldsToSalesQuoteRow < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_quote_rows, :credit_note_unit_cost_price, :decimal, unsigned: false, default: 0.0
    add_column :sales_quote_rows, :tax_type, :string, default: nil
    change_column :sales_quote_rows, :unit_selling_price, :decimal, unsigned: false
    change_column :sales_quote_rows,:converted_unit_selling_price, :decimal, unsigned: false
  end
end
