class AddColumnsToPoRequestRow < ActiveRecord::Migration[5.2]
  def change
    add_column :po_request_rows, :default_currency, :string
    add_column :po_request_rows, :unit_price_with_selected_currency , :decimal
  end
end
