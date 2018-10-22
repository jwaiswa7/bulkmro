class Customers::CartsController < ApplicationController

  def show
    @cart_items = current_cart.cart_items
  end

  # def add_cart_item
  # 	@cart_items.create_cart_item({
  # 		product_id: params[:product_id]
  # 	})
  # end 
   
# private

  # def get_cart
  # 	current_cart
  # end

end
