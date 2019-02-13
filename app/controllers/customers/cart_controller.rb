class Customers::CartController < Customers::BaseController
  before_action :set_cart

  def show
    authorize @cart
  end

  def update
    authorize @cart

    @cart.assign_attributes(cart_params)

    if @cart.save
      if params["show_cart"]
        redirect_to customers_cart_path
      else
        redirect_to final_checkout_customers_checkout_path
      end
    else
      render "show"
    end
  end

  def checkout
    authorize @cart
  end

  def empty_cart
    authorize @cart
    @cart.items.destroy_all

    redirect_to customers_products_path
  end

  def update_billing_address
    authorize @cart
    @cart.update_attributes(billing_address_id: params[:cart][:billing_address_id].to_i, po_reference: params[:cart][:po_reference])

    redirect_to final_checkout_customers_checkout_path(next_step: "shipping")
  end

  def update_shipping_address
    authorize @cart
    @cart.update_attributes(shipping_address_id: params[:cart][:shipping_address_id].to_i)

    redirect_to final_checkout_customers_checkout_path(next_step: "special_instructions")
  end

  def update_special_instructions
    authorize @cart
    @cart.update_attributes(special_instructions: params[:cart][:special_instructions].to_s)

    redirect_to final_checkout_customers_checkout_path(next_step: "payment_method")
  end

  def update_payment_method
    authorize @cart
    @cart.update_attributes(payment_method: params[:cart][:payment_method].to_s)
    redirect_to final_checkout_customers_checkout_path(next_step: "summary")
  end

  private
    def set_cart
      @cart = current_cart
    end

    def cart_params
      params.require(:cart).permit(items_attributes: [:quantity, :id])
    end
end
