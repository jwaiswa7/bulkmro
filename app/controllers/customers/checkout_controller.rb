class Customers::CheckoutController < Customers::BaseController

  def final_checkout
    authorize :checkout
    @cart = current_cart

    if params[:page] == "edit_cart"
      @cart.assign_attributes(cart_params)
      @cart.save
    end

    if params["show_cart"]
      redirect_to customers_cart_path
    end
  end

  private

  def cart_params
    params.require(:cart).permit(items_attributes: [:quantity, :id])
  end
end