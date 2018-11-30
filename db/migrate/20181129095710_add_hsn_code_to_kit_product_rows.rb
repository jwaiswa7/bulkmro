class AddHsnCodeToKitProductRows < ActiveRecord::Migration[5.2]
  def change
    add_reference :kit_product_rows, :tax_code, foreign_key: true
    add_reference :kit_product_rows, :tax_rate, foreign_key: true
  end
end
