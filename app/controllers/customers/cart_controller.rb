class Customers::CartController < Customers::BaseController

  def show
    @cart = current_cart
    authorize @cart
  end

  def checkout
    authorize current_cart
  end

end
