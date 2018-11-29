class Customers::CartController < Customers::BaseController
  before_action :set_cart

  def show
    authorize @cart
  end

  def checkout
    authorize @cart
  end

  def empty_cart
    authorize @cart
    debugger
    @cart.items.destroy_all

    redirect_to customers_products_path
  end

  def update_cart

  end

  def update_billing_address
    authorize @cart
    @cart.update_attributes(default_billing_address_id: params[:cart][:default_billing_address_id].to_i)

    redirect_to final_checkout_customers_checkout_path(next_step: 'shipping')
  end

  def update_shipping_address
    authorize @cart
    @cart.update_attributes(default_shipping_address_id: params[:cart][:default_shipping_address_id].to_i)

    redirect_to final_checkout_customers_checkout_path(next_step: 'po_reference')
  end

  def add_po_number
    authorize @cart
    @cart.update_attributes(po_reference: params[:cart][:po_reference].to_i)

    redirect_to final_checkout_customers_checkout_path(next_step: 'summary')
  end

  private

  def set_cart
    @cart = current_cart
  end
end
