class FixColumnName < ActiveRecord::Migration[5.2]
  def change
    rename_column :po_request_rows, :unit_price_with_selected_currency, :selected_currency_up
  end
end
