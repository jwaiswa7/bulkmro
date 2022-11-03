class AddCustomerProductToWishListItem < ActiveRecord::Migration[5.2]
  def change
    add_column :wish_list_items, :customer_product_id, foreign_key: true
  end
end
