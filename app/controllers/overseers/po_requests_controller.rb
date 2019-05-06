class Overseers::PoRequestsController < Overseers::BaseController
  before_action :set_po_request, only: [:show, :edit, :update, :cancel_porequest, :render_cancellation_form]
  before_action :set_notification, only: [:update, :cancel_porequest]

  def pending_and_rejected
    @po_requests = filter_by_status(:pending_and_rejected)
    authorize @po_requests

    respond_to do |format|
      format.json {render 'index'}
      format.html {render 'index'}
    end
  end

  def cancelled
    @po_requests = filter_by_status(:cancelled)
    authorize @po_requests

    respond_to do |format|
      format.json {render 'index'}
      format.html {render 'index'}
    end
  end

  def under_amend
    @po_requests = filter_by_status(:under_amend)
    authorize @po_requests

    respond_to do |format|
      format.json {render 'index'}
      format.html {render 'index'}
    end
  end

  def amended
    @po_requests = filter_by_status(:amended)
    authorize @po_requests

    respond_to do |format|
      format.json {render 'index'}
      format.html {render 'index'}
    end
  end

  def index
    @po_requests = filter_by_status(:handled)
    authorize @po_requests
  end

  def filter_by_status(scope)
    ApplyDatatableParams.to(policy_scope(PoRequest.all.send(scope).order(id: :desc)), params)
  end

  def show
    authorize @po_request
    # service = Services::Overseers::CompanyReviews::CreateCompanyReview.new(@po_request.sales_order, current_overseer, @po_request, 'Sales')
    @company_reviews = [@po_request.company_reviews.where(created_by: current_overseer, survey_type: 'Sales', company: @po_request.supplier ).first_or_create]
  end

  def new
    if params[:sales_order_id].present?
      @sales_order = SalesOrder.find(params[:sales_order_id])
      @po_request = PoRequest.new(overseer: current_overseer, sales_order: @sales_order, inquiry: @sales_order.inquiry)
      @sales_order.rows.each do |sales_order_row|
        @po_request.rows.where(sales_order_row: sales_order_row).first_or_initialize
      end

      authorize @po_request
    elsif params[:stock_inquiry_id].present?
      @inquiry = Inquiry.find(params[:stock_inquiry_id])
      @po_request = PoRequest.new(overseer: current_overseer, inquiry: @inquiry, po_request_type: :'Stock')

      authorize @po_request
    else
      redirect_to overseers_po_requests_path
    end
  end

  def create
    @po_request = PoRequest.new(po_request_params.merge(overseer: current_overseer))
    authorize @po_request

    if @po_request.valid?
      ActiveRecord::Base.transaction do
        @po_request.save!
        @po_request_comment = PoRequestComment.new(message: 'PO Request submitted.', po_request: @po_request, overseer: current_overseer)
        @po_request_comment.save!
      end

      redirect_to edit_overseers_po_request_path(@po_request), notice: flash_message(@po_request, action_name)
    else
      render 'new'
    end
  end

  def edit
    authorize @po_request
    # service = Services::Overseers::CompanyReviews::CreateCompanyReview.new(@po_request.sales_order, current_overseer, @po_request, 'Sales')
    @company_reviews = [@po_request.company_reviews.where(created_by: current_overseer, survey_type: 'Sales', company: @po_request.supplier ).first_or_create]
  end

  def update
    @po_request.assign_attributes(po_request_params.merge(overseer: current_overseer))
    authorize @po_request
    if @po_request.valid?
      # todo allow only in case of zero form errors
      row_updated_message = ''
      messages = FieldModifiedMessage.for(@po_request, ['contact_email', 'contact_phone', 'contact_id', 'payment_option_id', 'bill_from_id', 'ship_from_id', 'bill_to_id', 'ship_to_id', 'status', 'supplier_po_type', 'late_lead_date_reason', 'other_rejection_reason'])
      @po_request.rows.each do |po_request_row|
        updated_row_fields = FieldModifiedMessage.for(po_request_row, ['quantity', 'tax_code_id', 'tax_rate_id', 'discount_percentage', 'unit_price', 'lead_time'], po_request_row.product.sku)
        row_updated_message += updated_row_fields
      end
      if messages.present? || row_updated_message.present?
        @po_request.comments.create(message: "#{messages} \r\n #{row_updated_message}", overseer: current_overseer)
      end

      @po_request = autoupdate_statuses(@po_request)
      if @po_request.status_changed?
        service = Services::Overseers::PoRequests::Update.new(@po_request, current_overseer)
        @po_request_comment = service.call
        # sends notification
        tos = (Services::Overseers::Notifications::Recipients.logistics_owners.include? current_overseer.email) ? [@po_request.created_by.email, @po_request.inquiry.inside_sales_owner.email] : Services::Overseers::Notifications::Recipients.logistics_owners
        comment = @po_request_comment.present? ? @po_request_comment.message : nil
        @notification.send_po_request_update(
          tos - [current_overseer.email],
          action_name.to_sym,
          @po_request,
          overseers_po_request_path(@po_request),
          @po_request.id,
          comment,
        )
      else
        @po_request.save!
      end

      redirect_to overseers_po_request_path(@po_request), notice: flash_message(@po_request, action_name)
    else
      render 'edit'
    end
  end

  def cancel_porequest
    @po_request.assign_attributes(po_request_params.merge(overseer: current_overseer))
    authorize @po_request
    if @po_request.valid?
      service = Services::Overseers::PoRequests::Update.new(@po_request, current_overseer)
      @po_request_comment = service.call

      tos = (Services::Overseers::Notifications::Recipients.logistics_owners.include? current_overseer.email) ? [@po_request.created_by.email, @po_request.inquiry.inside_sales_owner.email] : Services::Overseers::Notifications::Recipients.logistics_owners
      @notification.send_po_request_update(
        tos - [current_overseer.email],
        action_name.to_sym,
        @po_request,
        overseers_po_request_path(@po_request),
        @po_request.id,
        @po_request.last_comment.message,
      )
      render json: {success: 1, message: 'Successfully updated '}, status: 200
    elsif @po_request.status == 'Cancelled'
      render json: {success: 0, message: 'Cannot cancel this PO Request.'}, status: 200
    else
      render json: {success: 0, message: 'Cannot reject this PO Request.'}, status: 200
    end
  end

  def render_cancellation_form
    authorize @po_request
    respond_to do |format|
      format.html {render partial: 'cancel_porequest', locals: {purpose: params[:purpose]}}
    end
  end

  def autoupdate_statuses(po_request)
    @po_request = po_request
    @po_request.status = 'Supplier PO: Created Not Sent' if @po_request.purchase_order.present? && @po_request.status == 'Supplier PO: Request Pending'
    @po_request.status = 'Supplier PO: Request Pending' if @po_request.status == 'Supplier PO Request Rejected' && policy(@po_request).manager_or_sales?
    @po_request.status = 'Supplier PO: Amendment Pending' if (@po_request.status == 'Supplier PO: Created Not Sent' || @po_request.status == 'Supplier PO Sent') && policy(@po_request).manager_or_sales?
    @po_request
  end

  def pending_stock_approval
    @po_requests = ApplyDatatableParams.to(PoRequest.all.pending_stock_po.order(id: :desc), params)
    authorize @po_requests

    respond_to do |format|
      format.json {render 'index'}
      format.html {render 'index'}
    end
  end

  def stock
    @po_requests = ApplyDatatableParams.to(PoRequest.all.stock_po.order(id: :desc), params)
    authorize @po_requests

    respond_to do |format|
      format.json {render 'index'}
      format.html {render 'index'}
    end
  end

  def completed_stock
    @po_requests = ApplyDatatableParams.to(PoRequest.all.completed_stock_po.order(id: :desc), params)
    authorize @po_requests

    respond_to do |format|
      format.json {render 'index'}
      format.html {render 'index'}
    end
  end

  def add_comment
    authorize @po_request
    respond_to do |format|
      format.html
      format.js
    end

  end

  private

    def po_request_params
      params.require(:po_request).permit(
        :id,
        :inquiry_id,
        :sales_order_id,
        :purchase_order_id,
        :logistics_owner_id,
        :contact_email,
        :contact_phone,
        :contact_id,
        :payment_option_id,
        :bill_from_id,
        :ship_from_id,
        :bill_to_id,
        :ship_to_id,
        :status,
        :supplier_po_type,
        :supplier_committed_date,
        :cancellation_reason,
        :rejection_reason,
        :late_lead_date_reason,
        :stock_status,
        :requested_by_id,
        :approved_by_id,
        :supplier_id,
        comments_attributes: [:id, :message, :created_by_id],
        rows_attributes: [:id, :sales_order_row_id, :product_id, :_destroy, :status, :quantity, :tax_code_id, :tax_rate_id, :discount_percentage, :unit_price, :lead_time, :converted_unit_selling_price, :product_unit_selling_price, :conversion],
        attachments: []
      )
    end

    def set_po_request
      @po_request = PoRequest.find(params[:id])
    end
end
