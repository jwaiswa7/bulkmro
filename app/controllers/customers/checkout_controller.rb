class Customers::CheckoutController < Customers::BaseController
  def final_checkout
    authorize_acl :checkout
    @cart = current_cart
  end

  def show
    authorize_acl :checkout
    redirect_to customers_cart_path
  end
end
