class AddProductsToPoRequestRows < ActiveRecord::Migration[5.2]
  def change
    add_reference :po_request_rows, :product, foreign_key: true
    add_reference :po_request_rows, :brand, foreign_key: true
    add_reference :po_request_rows, :tax_code, foreign_key: true
    add_reference :po_request_rows, :tax_rate, foreign_key: true
    add_reference :po_request_rows, :measurement_unit, foreign_key: true
  end
end
