class AddProductUnitSellingPrice < ActiveRecord::Migration[5.2]
  def change
    add_column :po_request_rows, :product_unit_selling_price , :decimal
    add_column :po_request_rows, :conversion , :decimal
  end
end
