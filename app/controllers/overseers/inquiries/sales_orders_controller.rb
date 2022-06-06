class Overseers::Inquiries::SalesOrdersController < Overseers::Inquiries::BaseController
  before_action :set_sales_order, only: [:show, :proforma, :edit, :update, :new_confirmation, :create_confirmation,
                                         :resync, :edit_mis_date, :update_mis_date, :fetch_order_data, :relationship_map,
                                         :get_relationship_map_json, :new_accounts_confirmation, :create_account_confirmation, :order_cancellation_modal, :order_cancellation_modal_by_isp, :cancellation, :isp_order_cancellation, :revise_committed_delivery_date, :update_revised_committed_delivery_date, :isp_so_cancellation_email]
  before_action :set_notification, only: [:create_confirmation, :create_account_confirmation]

  def index
    @model_name = 'sales_orders'
    @sales_orders = @inquiry.sales_orders
    authorize_acl @sales_orders

    respond_to do |format|
      format.html {}
    end
  end

  def autocomplete
    @sales_orders = @inquiry.sales_orders.where.not(order_number: nil)
    authorize_acl @sales_orders
  end

  def show
    authorize_acl @sales_order
    respond_to do |format|
      format.html {}
      format.pdf do
        render_pdf_for @sales_order
      end
    end
  end

  def proforma
    authorize_acl @sales_order, 'show_pdf'

    respond_to do |format|
      format.pdf do
        render_pdf_for @sales_order, proforma: true
      end
    end
  end

  def new
    @sales_quote = SalesQuote.find(params[:sales_quote_id])
    @sales_order = Services::Overseers::SalesOrders::BuildFromSalesQuote.new(@sales_quote, current_overseer).call
    authorize_acl :sales_order, 'new'
  end

  def new_revision
    @old_sales_order = @inquiry.sales_orders.find(params[:id])
    @sales_order = Services::Overseers::SalesOrders::BuildFromSalesQuote.new(@old_sales_order.sales_quote, current_overseer).call
    authorize_acl @old_sales_order
    render 'new'
  end

  def create
    @sales_order = SalesOrder.new(sales_order_params.merge(overseer: current_overseer))
    authorize_acl @sales_order
    callback_method = %w(save save_and_confirm).detect { |action| params[action] }

    if callback_method.present? && send(callback_method)
      redirect_to overseers_inquiry_sales_orders_path(@inquiry), notice: flash_message(@inquiry, action_name) unless performed?
    else
      render 'new'
    end
  end

  def edit
    authorize_acl @sales_order
  end

  def update
    @sales_order.assign_attributes(sales_order_params.merge(overseer: current_overseer))
    authorize_acl @sales_order

    callback_method = %w(save save_and_confirm).detect { |action| params[action] }

    if callback_method.present? && send(callback_method)
      redirect_to overseers_inquiry_sales_orders_path(@inquiry), notice: flash_message(@inquiry, action_name) unless performed?
    else
      render 'edit'
    end
  end

  def debugging
    authorize_acl :sales_order
    @sales_order = SalesOrder.find(params['id'])
    @remote_requests = RemoteRequest.where(subject_type: 'SalesOrder', subject_id: @sales_order.id)
    @callback_requests = CallbackRequest.sales_order_callbacks(@sales_order.id)
  end

  def create_confirmation
    authorize_acl @sales_order

    if @sales_order.not_confirmed?
      @confirmation = @sales_order.build_confirmation(overseer: current_overseer)
      Services::Overseers::Inquiries::UpdateStatus.new(@sales_order, :order_confirmed).call
      ActiveRecord::Base.transaction do
        @confirmation.save!
        @sales_order.update_attributes(status: 'Requested')
        @sales_order.update_attributes(sent_at: Time.now)
      end
      @notification.send_order_confirmation(
        @inquiry,
          action_name.to_sym,
          @sales_order,
          overseers_inquiry_comments_path(@inquiry, sales_order_id: @sales_order.to_param, show_to_customer: false),
          @sales_order.inquiry.inquiry_number.to_s
      )

      if Settings.sales_order.default_manager_approved
        Services::Overseers::SalesOrders::DefaultManagerApproval.new(@sales_order, @notification).call
      end
    else
      @sales_order.update_attributes(sent_at: Time.now) if @sales_order.sent_at.blank?
    end

    if @sales_order.persisted?
      @sales_order.touch
      @sales_order.update_index
    end

    redirect_to overseers_inquiry_sales_orders_path(@inquiry), notice: flash_message(@inquiry, action_name)
  end

  def create_account_confirmation
    authorize_acl @sales_order

    Services::Overseers::SalesOrders::CreateSalesOrderInSap.new(@sales_order, params.merge(overseer: current_overseer), @notification).call

    redirect_to overseers_inquiry_sales_orders_path(@inquiry), notice: flash_message(@inquiry, action_name)
  end

  def new_confirmation
    authorize_acl @sales_order
  end

  def new_accounts_confirmation
    @modal_show = false
    @warehouse = @sales_order.sales_quote.bill_from.name
    if @sales_order.sales_quote.bill_from.series_code.present?
      date = Date.today
      year = date.year
      year = year - 1 if date.month < 4
      series_name = @sales_order.sales_quote.bill_from.series_code + ' ' + year.to_s
      @series = Series.where(document_type: 'Sales Order', series_name: series_name)
      if !@series.present?
        @modal_show = true
      end
    else
      @modal_show = true
    end
    authorize_acl @sales_order
  end

  def edit_mis_date
    if @sales_order.mis_date.blank?
      @sales_order.mis_date = @sales_order.created_at.strftime('%d-%b-%Y')
    end

    authorize_acl @sales_order
  end

  def update_mis_date
    @sales_order.assign_attributes(mis_date_params.merge(overseer: current_overseer))
    authorize_acl @sales_order

    if @sales_order.save
      redirect_to overseers_inquiry_sales_orders_path(@inquiry), notice: flash_message(@inquiry, action_name)
    else
      render 'edit'
    end
  end

  def revise_committed_delivery_date
    authorize_acl @sales_order
    render 'shared/layouts/revise_committed_delivery_date'
  end

  def update_revised_committed_delivery_date
    authorize_acl @sales_order

    if @sales_order.valid?
      @sales_order.assign_attributes(revised_committed_delivery_date: params['sales_order']['revised_committed_delivery_date'], revised_committed_deliveries: params['sales_order']['revised_committed_deliveries'])

      messages = FieldModifiedMessage.for(@sales_order, ['revised_committed_delivery_date'])
      if messages.present? && @sales_order.save
        @sales_order.inquiry.comments.create(sales_order: @sales_order, message: messages, overseer: current_overseer, revised_committed_delivery_date: true)
        # render json: {success: 1, message: 'Successfully updated '}, status: 200
      end

      redirect_to request.referrer, notice: flash_message(@sales_order, action_name)
    end
  end

  def resync
    authorize_acl @sales_order
    @sales_order.save_and_sync
    redirect_to so_sync_pending_overseers_sales_orders_path
  end

  def fetch_order_data
    authorize_acl @sales_order
    Services::Overseers::SalesOrders::FetchOrderData.new(@sales_order).call
    redirect_to overseers_inquiry_sales_orders_path(@inquiry)
  end

  def relationship_map
    authorize_acl @inquiry
  end

  def get_relationship_map_json
    authorize_acl @sales_order
    inquiry_json = Services::Overseers::Inquiries::RelationshipMap.new(@sales_order.inquiry, [@sales_order.sales_quote]).call
    render json: {data: inquiry_json}
  end

  def order_cancellation_modal
    authorize @sales_order
    respond_to do |format|
      format.html { render partial: 'cancellation' }
    end
  end

  def order_cancellation_modal_by_isp
    authorize @sales_order
    respond_to do |format|
      format.html { render partial: 'cancellation_by_isp' }
    end
  end

  def cancellation
    authorize_acl @sales_order
    @status = Services::Overseers::SalesOrders::CancelSalesOrder.new(@sales_order, sales_order_params.merge(status: 'Cancelled', remote_status: 'Cancelled by SAP')).call
    if @status.key?(:empty_message)
      render json: {error: 'Cancellation Message is Required'}, status: 500
    elsif @status[:status] == 'success'
      render json: {notice: @status[:message]}, status: 200
    elsif @status[:status] == 'failed'
      render json: {error: @status[:message]}, status: 500
    end
  end

  def isp_order_cancellation
    authorize_acl @sales_order
    if sales_order_params['comments_attributes']['0']['message'].present?
      @status = Services::Overseers::SalesOrders::CancelSalesOrder.new(@sales_order, sales_order_params.merge(status: 'Cancelled', remote_status: 'Cancelled by SAP')).call
      if @status[:status] == 'success'
        render json: {notice: @status[:message]}, status: 200
      elsif @status[:status] == 'failed'
        render json: {error: @status[:message]}, status: 500
      end
    else
      render json: {error: 'SO Cancellation Message is Required'}, status: 500
    end
  end

  def isp_so_cancellation_email
    authorize_acl @sales_order
    if sales_order_params['comments_attributes']['0']['message'].present?
      so_cancellation_reason = "Reason for SO Cancellation: #{sales_order_params['comments_attributes']['0']['message']}"
      @sales_order.comments.build(message: so_cancellation_reason, overseer: current_overseer, inquiry: @inquiry)
      @sales_order.save
      @email_message = @sales_order.email_messages.build(overseer: current_overseer, inquiry: @inquiry, email_type: 'Request for SO Cancellation')
      if Settings.domain == 'sprint.bulkmro.com'
        from = @inquiry.inside_sales_owner.try(:email)
        to = ["accounts@bulkmro.com", "ajay.kondal@bulkmro.com", "charudatt.mhatre@bulkmro.com"] 
        cc = [@inquiry.company.try(:sales_manager).try(:email), @inquiry.inside_sales_owner.try(:email)]
        subject = "Request for SO Cancellation for Inquiry ##{@sales_order.inquiry.inquiry_number} Sales Order ##{@sales_order.order_number}"
      else
        from = 'bulkmro007@gmail.com'
        to = 'bulkmro007@gmail.com'
        cc = ['bhumika.desai@bulkmro.com']
        subject = "Testing server - Request for SO Cancellation for Inquiry ##{@sales_order.inquiry.inquiry_number} Sales Order ##{@sales_order.order_number}"
      end
      @email_message.assign_attributes(
        from: from,
        to: to,
        cc: cc,
        subject: subject,
        body: SalesOrderMailer.request_cancel_so_email(@email_message).body.raw_source
      )
      if @email_message.save
        if SalesOrderMailer.send_request_cancel_so_email(@email_message).deliver_now
          render json: {notice: 'Email sent to Accounts team for cancellation!'}, status: 200
        else
          render json: {error: 'Email not sent! Something went wrong!!'}, status: 500
        end
      end
    else
      render json: {error: 'SO Cancellation Message is Required'}, status: 500
    end
  end

  private

    def save
      @sales_order.save
    end

    def save_and_confirm
      sales_orders_total = @sales_order.company.company_transactions_amounts.where(financial_year: Company.current_financial_year).last.total_amount
      @sales_order.legacy_metadata = { company_total: sales_orders_total }

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
          :reject,
          :approve,
          :revised_committed_delivery_date,
          custom_fields: [
              :reject_reasons,
              :message
          ],
          rows_attributes: [
              :id,
              :sales_order_id,
              :sales_quote_row_id,
              :quantity,
              :product_id,
              :_destroy
          ],
          comments_attributes: [
              :message,
              :inquiry_id,
              :created_by_id,
              :sales_order_id
          ]
      )
    end

    def mis_date_params
      params.require(:sales_order).permit(
        :mis_date,
      )
    end
end
