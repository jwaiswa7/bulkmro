class Customers::CartController < Customers::BaseController

  def show
    @cart = current_cart
    authorize @cart
  end

  def checkout
    authorize current_cart
  end

  def update_billing_address
    authorize current_cart
    current_cart.update_attributes(default_billing_address_id: params[:cart][:default_billing_address_id].to_i)
    redirect_to final_checkout_customers_checkouts_path
  end

  def update_shipping_address
    authorize current_cart
    current_cart.update_attributes(default_shipping_address_id: params[:cart][:default_shipping_address_id].to_i)
    redirect_to final_checkout_customers_checkouts_path
  end

  def add_po_number
    authorize current_cart
    current_cart.update_attributes(po_reference: params[:cart][:po_reference].to_i)
    redirect_to final_checkout_customers_checkouts_path
  end
end
