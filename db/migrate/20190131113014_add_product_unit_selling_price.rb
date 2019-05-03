class AddProductUnitSellingPrice < ActiveRecord::Migration[5.2]
  def change
    add_column :po_request_rows, :product_unit_selling_price , :decimal unless column_exists? :po_request_rows, :product_unit_selling_price
    add_column :po_request_rows, :conversion , :decimal unless column_exists? :po_request_rows, :conversion
  end
end