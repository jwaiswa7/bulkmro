class Customers::CartsController < Customers::BaseController

  def show
    @cart_items = current_cart.cart_items
  end

end
