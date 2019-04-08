class Customers::CheckoutController < Customers::BaseController
  def final_checkout
    authorize :checkout
    @cart = current_cart
  end

  def show
    authorize :checkout
    redirect_to customers_cart_path
  end
end
