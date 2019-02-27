class AddUnitPriceToPoRequestRows < ActiveRecord::Migration[5.2]
  def change
    add_column :po_request_rows, :unit_price, :decimal
  end
end
