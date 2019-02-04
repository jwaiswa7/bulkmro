class AddDiscountToPoRequestRows < ActiveRecord::Migration[5.2]
  def change
    add_column :po_request_rows, :discount_percentage, :decimal
  end
end
