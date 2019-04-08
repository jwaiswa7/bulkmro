class AddTaxAndMouToCustomerProduct < ActiveRecord::Migration[5.2]
  def change
    add_reference :customer_products, :tax_rate, foreign_key: true
    add_reference :customer_products, :tax_code, foreign_key: true
    add_reference :customer_products, :measurement_unit, foreign_key: true
  end
end
