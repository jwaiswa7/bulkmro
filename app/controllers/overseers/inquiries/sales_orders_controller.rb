class Overseers::Inquiries::SalesOrdersController < Overseers::Inquiries::BaseController
  before_action :set_sales_order, only: [:edit, :update, :confirmation]

  def index
    @sales_orders = @inquiry.sales_orders
    authorize @sales_orders
  end

  def new
    @sales_quote = @inquiry.sales_quotes.find(params[:sales_quote_id])
    @sales_order = Services::Overseers::SalesOrders::BuildFromSalesQuote.new(@sales_quote, current_overseer).call
    authorize @sales_quote, :new_sales_order?
  end

  def new_revision
    @old_sales_order = @inquiry.sales_orders.find(params[:id])
    @sales_order = Services::Overseers::SalesQuotes::BuildFromSalesQuote.new(@old_sales_order, current_overseer).call
    authorize @old_sales_order
    render 'new'
  end

  def create
    @sales_order = SalesOrder.new(sales_order_params.merge(:overseer => current_overseer))
    authorize @sales_order

    callback_method = %w(save save_and_send confirmation).detect {|action| params[action]}

    if callback_method == 'confirmation'
      send('save')
      redirect_to confirmation_overseers_inquiry_sales_order_path(@inquiry, @sales_order), notice: flash_message(@inquiry, action_name)
    elsif callback_method.present? && send(callback_method)
      redirect_to overseers_inquiry_sales_orders_path(@inquiry), notice: flash_message(@inquiry, action_name)
    else
      render 'new'
    end
  end

  def edit
    authorize @sales_order
  end

  def update
    @sales_order.assign_attributes(sales_order_params.merge(:overseer => current_overseer))
    authorize @sales_order

    callback_method = %w(save save_and_send confirmation).detect {|action| params[action]}

    if callback_method == 'confirmation'
      send('save')
      redirect_to confirmation_overseers_inquiry_sales_order_path(@inquiry), notice: flash_message(@inquiry, action_name)
    elsif callback_method.present? && send(callback_method)
      redirect_to overseers_inquiry_sales_orders_path(@inquiry), notice: flash_message(@inquiry, action_name)
    else
      render 'edit'
    end
  end

  def confirmation
    authorize @sales_order
  end

  private

  def save
    @sales_order.save
  end

  def save_and_send
    if validate_confirm
      @sales_order.assign_attributes(:sent_at => Time.now)
      @sales_order.save
    else
      false
    end
  end

  def set_sales_order
    @sales_order = @inquiry.sales_orders.find(params[:id])
  end

  def sales_order_params
    params.require(:sales_order).permit(
        :sales_quote_id,
        :parent_id,
        :rows_attributes => [
            :id,
            :sales_order_id,
            :sales_quote_row_id,
            :quantity,
            :_destroy
        ]
    )
  end

  def validate_confirm
    if params[:confirm_ord_values] == 1 && params[:confirm_tax_rates] == 1 && params[:confirm_hsn_codes] == 1 && params[:confirm_billing_address] == 1 && params[:confirm_shipping_address] == 1 && params[:confirm_customer_po_no] == 1
      true
    else
      false
    end
  end
end