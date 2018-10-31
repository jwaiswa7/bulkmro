class Customers::CartsController < Customers::BaseController

  before_action :load_cart_items

  def show
  end

  def checkout
  end

  private

  def load_cart_items
    @cart_items = current_cart.cart_items
  end

end
