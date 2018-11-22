class Customers::CheckoutsController < Customers::BaseController
  def final_checkout
    authorize :checkout
    @cart = current_cart
  end
end