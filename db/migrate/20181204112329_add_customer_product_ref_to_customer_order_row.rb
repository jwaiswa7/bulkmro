class AddCustomerProductRefToCustomerOrderRow < ActiveRecord::Migration[5.2]
  def change
    add_reference :customer_order_rows, :customer_product, foreign_key: true
  end
end
