class Customers::CheckoutController < Customers::BaseController

  def final_checkout
    authorize :checkout
    @cart = current_cart
  end

  private
end