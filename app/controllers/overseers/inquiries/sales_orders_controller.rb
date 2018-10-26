class Overseers::Inquiries::SalesOrdersController < Overseers::Inquiries::BaseController
  before_action :set_sales_order, only: [:show, :proforma, :edit, :update, :new_confirmation, :create_confirmation, :resync]

  def index
    @sales_orders = @inquiry.sales_orders
    authorize @sales_orders

    respond_to do |format|
      format.html {}
    end
  end

  def show
    authorize @sales_order

    respond_to do |format|
      format.html {}
      format.pdf do
        render_pdf_for @sales_order
      end
    end
  end

  def proforma
    authorize @sales_order, :show_pdf?

    respond_to do |format|
      format.pdf do
        render_pdf_for @sales_order, {proforma: true}
      end
    end
  end

  def new
    @sales_quote = SalesQuote.find(params[:sales_quote_id])
    @sales_order = Services::Overseers::SalesOrders::BuildFromSalesQuote.new(@sales_quote, current_overseer).call
    authorize @sales_quote, :new_sales_order?
  end

  def new_revision
    @old_sales_order = @inquiry.sales_orders.find(params[:id])
    @sales_order = Services::Overseers::SalesOrders::BuildFromSalesQuote.new(@old_sales_order.sales_quote, current_overseer).call
    authorize @old_sales_order
    render 'new'
  end

  def create
    @sales_order = SalesOrder.new(sales_order_params.merge(:overseer => current_overseer))
    authorize @sales_order

    callback_method = %w(save save_and_confirm).detect {|action| params[action]}

    if callback_method.present? && send(callback_method)
      redirect_to overseers_inquiry_sales_orders_path(@inquiry), notice: flash_message(@inquiry, action_name) unless performed?
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

    callback_method = %w(save save_and_confirm).detect {|action| params[action]}

    if callback_method.present? && send(callback_method)
      redirect_to overseers_inquiry_sales_orders_path(@inquiry), notice: flash_message(@inquiry, action_name) unless performed?
    else
      render 'edit'
    end
  end

  def create_confirmation
    authorize @sales_order

    if @sales_order.not_confirmed?
      @confirmation = @sales_order.build_confirmation(:overseer => current_overseer)

      ActiveRecord::Base.transaction do
        @confirmation.save!
        @sales_order.update_attributes(:sent_at => Time.now)
      end
    else
      @sales_order.update_attributes(:sent_at => Time.now) if @sales_order.sent_at.blank?
    end

    if @sales_order.persisted?
      @sales_order.touch
      SalesOrdersIndex::SalesOrder.import([@sales_order.id])
    end

    redirect_to overseers_inquiry_sales_orders_path(@inquiry), notice: flash_message(@inquiry, action_name)
  end

  def new_confirmation
    authorize @sales_order
  end

  def resync
    authorize @sales_order
    if @sales_order.save_and_sync
      redirect_to overseers_inquiry_sales_orders_path(@inquiry), notice: flash_message(@inquiry, action_name)
    end
  end

  private

  def save
    @sales_order.save
  end

  def save_and_confirm
    if @sales_order.save
      redirect_to new_confirmation_overseers_inquiry_sales_order_path(@inquiry, @sales_order), notice: flash_message(@inquiry, action_name)
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
end