class Customers::CartController < Customers::BaseController
  before_action :set_cart

  def show
    authorize @cart
  end

  def punchout
    authorize @cart
  end

  def punchout_cart
    authorize @cart
    service = Services::Api::OrderResponse.new(@cart, current_api_request)
    @endpoint = current_api_request.payload["Request"]["PunchOutSetupRequest"]["BrowserFormPost"]["URL"]
    @data = service.call

    # session[:cart_id] = @cart.id
    # current_customers_contact.cart = nil
    # current_customers_contact.save
    render 'punchout_cart'
  end

  def manual_punchout
    authorize @cart
    service = Services::Api::OrderResponse.new(@cart, current_api_request)
    @endpoint = current_api_request.payload["Request"]["PunchOutSetupRequest"]["BrowserFormPost"]["URL"]
    # @endpoint = 'https://webhook.site/d31d22e4-69a1-4d48-b7d9-2bf585b52e62'
    @data = service.call
  end

  def update
    authorize @cart

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
    authorize @cart
  end

  def empty_cart
    authorize @cart
    @cart.items.destroy_all

    redirect_to customers_products_path
  end

  def update_cart_details
    authorize @cart
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
