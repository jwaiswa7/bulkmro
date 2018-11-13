class Customers::CartController < Customers::BaseController

  def show
    authorize current_cart
  end

  def checkout
    authorize current_cart
  end

  private
end
