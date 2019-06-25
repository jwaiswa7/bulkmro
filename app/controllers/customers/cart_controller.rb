class Customers::CartController < Customers::BaseController
  before_action :set_cart

  def show
    authorize_acl @cart
  end

  def update
    authorize_acl @cart

    @cart.assign_attributes(cart_params)

    if @cart.save
      if params['show_cart']
        redirect_to customers_cart_path
      else
        redirect_to final_checkout_customers_checkout_path
      end
    else
      render 'show'
    end
  end

  def checkout
    authorize_acl @cart
  end

  def empty_cart
    authorize_acl @cart
    @cart.items.destroy_all

    redirect_to customers_products_path
  end

  def update_cart_details
    authorize_acl @cart
    @cart.assign_attributes(cart_params)
    @cart.save
    redirect_to final_checkout_customers_checkout_path(next_step: 'summary')
  end

  private

    def set_cart
      @cart = current_cart
    end

    def cart_params
      params.require(:cart).permit(:id, :billing_address_id, :shipping_address_id, :po_reference, :customer_po_sheet, :special_instructions, :payment_method, items_attributes: [:quantity, :id])
    end
end
