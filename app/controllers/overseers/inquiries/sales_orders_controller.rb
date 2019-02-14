

class Overseers::Inquiries::SalesOrdersController < Overseers::Inquiries::BaseController
  before_action :set_sales_order, only: [:show, :proforma, :edit, :update, :new_confirmation, :create_confirmation, :resync, :edit_mis_date, :update_mis_date, :fetch_order_data]

  def index
    @sales_orders = @inquiry.sales_orders
    authorize @sales_orders

    respond_to do |format|
      format.html { }
    end
  end

  def autocomplete
    @sales_orders = @inquiry.sales_orders
    authorize @sales_orders
  end

  def show
    authorize @sales_order

    respond_to do |format|
      format.html { }
      format.pdf do
        render_pdf_for @sales_order
      end
    end
  end

  def proforma
    authorize @sales_order, :show_pdf?

    respond_to do |format|
      format.pdf do
        render_pdf_for @sales_order, proforma: true
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
    @sales_order = SalesOrder.new(sales_order_params.merge(overseer: current_overseer))
    authorize @sales_order

    callback_method = %w(save save_and_confirm).detect { |action| params[action] }

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
    @sales_order.assign_attributes(sales_order_params.merge(overseer: current_overseer))
    authorize @sales_order

    callback_method = %w(save save_and_confirm).detect { |action| params[action] }

    if callback_method.present? && send(callback_method)
      redirect_to overseers_inquiry_sales_orders_path(@inquiry), notice: flash_message(@inquiry, action_name) unless performed?
    else
      render 'edit'
    end
  end

  def debugging
    authorize :sales_order
    @sales_order = SalesOrder.find(params['id'])
    @remote_requests = RemoteRequest.where(subject_type: 'SalesOrder', subject_id: @sales_order.id)
    @callback_requests = CallbackRequest.sales_order_callbacks(@sales_order.id)
  end

  def create_confirmation
    authorize @sales_order

    if @sales_order.not_confirmed?
      @confirmation = @sales_order.build_confirmation(overseer: current_overseer)
      Services::Overseers::Inquiries::UpdateStatus.new(@sales_order, :order_confirmed).call
      ActiveRecord::Base.transaction do
        @confirmation.save!
        @sales_order.update_attributes(status: 'Requested')
        @sales_order.update_attributes(sent_at: Time.now)
      end
      # chat_message = Services::Overseers::ChatMessages::SendChat.new
      # message = chat_message.message_body(
      #     fallback: "New Order for approval",
      #     pretext: "New Order for approval",
      #     author_name: "Created by: " + @sales_order.created_by.full_name,
      #     inquiry_number: @sales_order.inquiry_id,
      #     order_no: @sales_order.id
      #     )
      # chat_message.send_chat_message(@inquiry.sales_manager.slack_uid, message)
    else
      @sales_order.update_attributes(sent_at: Time.now) if @sales_order.sent_at.blank?
    end

    if @sales_order.persisted?
      @sales_order.touch
      @sales_order.update_index
    end

    redirect_to overseers_inquiry_sales_orders_path(@inquiry), notice: flash_message(@inquiry, action_name)
  end

  def new_confirmation
    authorize @sales_order
  end

  def edit_mis_date
    if @sales_order.mis_date.blank?
      @sales_order.mis_date = @sales_order.created_at.strftime('%d-%b-%Y')
    end

    authorize @sales_order
  end

  def update_mis_date
    @sales_order.assign_attributes(mis_date_params.merge(overseer: current_overseer))
    authorize @sales_order

    if @sales_order.save
      redirect_to overseers_inquiry_sales_orders_path(@inquiry), notice: flash_message(@inquiry, action_name)
    else
      render 'edit'
    end
  end

  def resync
    authorize @sales_order
    if @sales_order.save_and_sync
      redirect_to overseers_inquiry_sales_orders_path(@inquiry), notice: flash_message(@inquiry, action_name)
    end
  end

  def fetch_order_data
    authorize @sales_order
    Services::Overseers::SalesOrders::FetchOrderData.new(@sales_order).call
    redirect_to overseers_inquiry_sales_orders_path(@inquiry)
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
        :mis_date,
          :sales_quote_id,
          :parent_id,
          rows_attributes: [
              :id,
              :sales_order_id,
              :sales_quote_row_id,
              :quantity,
              :_destroy
          ]
      )
    end

    def mis_date_params
      params.require(:sales_order).permit(
        :mis_date,
      )
    end
end
