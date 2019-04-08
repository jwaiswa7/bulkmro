class AddCustomerProductRefToCartItems < ActiveRecord::Migration[5.2]
  def change
    add_reference :cart_items, :customer_product, foreign_key: true
  end
end
