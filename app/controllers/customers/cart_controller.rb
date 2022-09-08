class Customers::CartController < Customers::BaseController
  before_action :set_cart

  def add_item 
    authorize @cart
    @cart_item = @cart.items.new(product_id: params[:product_id], customer_product_id: params[:customer_product_id])
    @cart_item.save
    respond_to do |format|
      format.js { }
    end
  end

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
    # @endpoint = 'https://webhook.site/d31d22e4-69a1-4d48-b7d9-2bf585b52e62'
    @data = service.call

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
      elsif is_api_request?
        redirect_to punchout_customers_cart_path
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
    inquiry = Inquiry.where(company_id: current_customers_contact.company.id , customer_po_number: cart_params["po_reference"]).last if cart_params["po_reference"].present?
    if inquiry
      @cart.assign_attributes(cart_params)
      @cart.save
      redirect_to final_checkout_customers_checkout_path(next_step: 'summary')
    else
      redirect_to final_checkout_customers_checkout_path(), notice: "The entered PO number is invalid, please contact the Account Manager."
    end
  end

  private

    def set_cart
      @cart = current_cart
    end

    def cart_params
      params.require(:cart).permit(:id, :billing_address_id, :shipping_address_id, :po_reference, :customer_po_sheet, :special_instructions, :payment_method, items_attributes: [:quantity, :id])
    end
end
