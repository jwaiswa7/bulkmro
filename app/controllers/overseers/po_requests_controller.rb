class Overseers::PoRequestsController < Overseers::BaseController
  before_action :set_po_request, only: [:show, :edit, :update, :cancel_porequest, :render_cancellation_form, :render_comment_form, :render_modal_form, :add_comment, :new_purchase_order, :create_purchase_order, :manager_amended, :reject_purchase_order_modal]
  before_action :set_notification, only: [:update, :cancel_porequest, :create_purchase_order, :manager_amended]
  before_action :set_product, only: [:product_resync_inventory]
  def pending_and_rejected
    @po_requests = filter_by_status(:pending_and_rejected)
    authorize_acl @po_requests

    respond_to do |format|
      format.json {render 'index'}
      format.html {render 'index'}
    end
  end

  def cancelled
    @po_requests = filter_by_status(:cancelled)
    authorize_acl @po_requests

    respond_to do |format|
      format.json {render 'index'}
      format.html {render 'index'}
    end
  end

  def under_amend
    @po_requests = filter_by_status(:under_amend)
    authorize_acl @po_requests

    respond_to do |format|
      format.json {render 'index'}
      format.html {render 'index'}
    end
  end

  def amended
    @po_requests = filter_by_status(:amended_and_sent)
    authorize_acl @po_requests

    respond_to do |format|
      format.json {render 'index'}
      format.html {render 'index'}
    end
  end

  def index
    @po_requests = filter_by_status(:handled)
    authorize_acl @po_requests
  end

  def filter_by_status(scope)
    ApplyDatatableParams.to(policy_scope(PoRequest.all.send(scope).order(id: :desc)), params)
  end

  def show
    authorize_acl @po_request
    # service = Services::Overseers::CompanyReviews::CreateCompanyReview.new(@po_request.sales_order, current_overseer, @po_request, 'Sales')
    if current_overseer.logistics?
      @company_reviews = [@po_request.company_reviews.where(created_by: current_overseer, survey_type: 'Logistics', company: @po_request.supplier).first_or_create]
    elsif !current_overseer.accounts?
      @company_reviews = [@po_request.company_reviews.where(created_by: current_overseer, survey_type: 'Sales', company: @po_request.supplier).first_or_create]
    end
  end

  def new
    @supplier_index = 1
    if params[:sales_order_id].present?
      @sales_order = SalesOrder.find(params[:sales_order_id])
      @po_request = PoRequest.new(overseer: current_overseer, sales_order: @sales_order, inquiry: @sales_order.inquiry)
      @sales_order.rows.each do |sales_order_row|
        @po_request.rows.where(sales_order_row: sales_order_row).first_or_initialize
      end

      authorize_acl @po_request
    elsif params[:stock_inquiry_id].present?
      @inquiry = Inquiry.find(params[:stock_inquiry_id])
      @po_request = PoRequest.new(overseer: current_overseer, inquiry: @inquiry, po_request_type: :'Stock')

      authorize_acl @po_request
    else
      redirect_to overseers_po_requests_path
    end
  end

  def create
    @po_request = PoRequest.new(po_request_params.merge(overseer: current_overseer))
    authorize_acl @po_request

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
    authorize_acl @po_request
    # service = Services::Overseers::CompanyReviews::CreateCompanyReview.new(@po_request.sales_order, current_overseer, @po_request, 'Sales')
    @supplier_index = 1
    if current_overseer.logistics?
      @company_reviews = [@po_request.company_reviews.where(created_by: current_overseer, survey_type: 'Logistics', company: @po_request.supplier).first_or_create]
    elsif !current_overseer.accounts?
      @company_reviews = [@po_request.company_reviews.where(created_by: current_overseer, survey_type: 'Sales', company: @po_request.supplier).first_or_create]
    end
  end

  def update
    @po_request.assign_attributes(po_request_params.merge(overseer: current_overseer))
    authorize_acl @po_request
    if @po_request.valid?
      po_request_row_ids = []
      params[:po_request][:rows_attributes].each do |key, value|
        if value.key?('_destroy')
          po_request_row_ids << value['id']
        end
      end

      if @po_request.purchase_order.present? && po_request_row_ids.present?
        @po_request.purchase_order.rows.where(po_request_row_id: po_request_row_ids).update_all(po_request_row_id: nil)
      end

      # todo allow only in case of zero form errors
      row_updated_message = ''
      messages = FieldModifiedMessage.for(@po_request, ['contact_email', 'contact_phone', 'contact_id', 'payment_option_id', 'bill_from_id', 'ship_from_id', 'bill_to_id', 'ship_to_id', 'status', 'supplier_po_type', 'late_lead_date_reason', 'other_rejection_reason'])
      @po_request.rows.each do |po_request_row|
        updated_row_fields = FieldModifiedMessage.for(po_request_row, ['quantity', 'tax_code_id', 'tax_rate_id','measurement_unit_id', 'discount_percentage', 'unit_price', 'lead_time'], po_request_row.product.sku)
        row_updated_message += updated_row_fields
      end
      if messages.present? || row_updated_message.present?
        @po_request.comments.create(message: "#{messages} \r\n #{row_updated_message}", overseer: current_overseer)
      end

      @po_request = autoupdate_statuses(@po_request)
      if @po_request.status_changed?
        service = Services::Overseers::PoRequests::Update.new(@po_request, current_overseer, @notification, overseers_po_request_path(@po_request), action_name)
        @po_request_comment = service.call
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
    authorize_acl @po_request
    if @po_request.status == 'Cancelled'
      if @po_request.cancellation_reason.present?
        service = Services::Overseers::PoRequests::Update.new(@po_request, current_overseer, @notification, overseers_po_request_path(@po_request), action_name)
        @po_request_comment = service.call
        render json: {success: 1, message: 'Successfully updated '}, status: 200
      else
        render json: {error: {base: 'Cancellation reason is required'}}, status: 500
      end
    elsif @po_request.valid?
      service = Services::Overseers::PoRequests::Update.new(@po_request, current_overseer, @notification, overseers_po_request_path(@po_request), action_name)
      @po_request_comment = service.call
      render json: {success: 1, message: 'Successfully updated '}, status: 200
    else
      render json: {error: @po_request.errors}, status: 500
    end
  end

  def render_modal_form
    authorize_acl @po_request
    respond_to do |format|
      if params[:title] == 'Comment'
        format.html {render partial: 'shared/layouts/add_comment', locals: {obj: @po_request, url: add_comment_overseers_po_request_path(@po_request), view_more: overseers_po_request_path(@po_request)}}
      else
        format.html {render partial: 'cancel_porequest', locals: {purpose: params[:title]}}
      end
    end
  end

  def add_comment
    @po_request.assign_attributes(po_request_params.merge(overseer: current_overseer))
    authorize_acl @po_request
    if @po_request.valid?
      if params['po_request']['comments_attributes']['0']['message'].present?
        ActiveRecord::Base.transaction do
          @po_request.save!
          @po_request_comment = PoRequestComment.new(message: '', po_request: @po_request, overseer: current_overseer)
        end
        render json: {success: 1, message: 'Successfully updated '}, status: 200
      else
        render json: {error: {base: 'Field cannot be blank!'}}, status: 500
      end
    else
      render json: {error: @po_request.errors}, status: 500
    end
  end

  def autoupdate_statuses(po_request)
    @po_request = po_request
    @po_request.status = 'Supplier PO: Created Not Sent' if @po_request.purchase_order.present? && @po_request.status == 'Supplier PO: Request Pending'
    @po_request.status = 'Supplier PO: Request Pending' if @po_request.status == 'Supplier PO Request Rejected' && policy(@po_request).manager_or_sales?
    @po_request.status = 'Supplier PO: Amendment Pending' if (@po_request.status == 'Supplier PO: Created Not Sent' || @po_request.status == 'Supplier PO Sent' || @po_request.status == 'Supplier PO: Amended') && policy(@po_request).manager_or_sales?
    @po_request
  end

  def pending_stock_approval
    @po_requests = ApplyDatatableParams.to(PoRequest.all.pending_stock_po.order(id: :desc), params)
    authorize_acl @po_requests

    respond_to do |format|
      format.json {render 'index'}
      format.html {render 'index'}
    end
  end

  def stock
    @po_requests = ApplyDatatableParams.to(PoRequest.all.stock_po.order(id: :desc), params)
    authorize_acl @po_requests

    respond_to do |format|
      format.json {render 'index'}
      format.html {render 'index'}
    end
  end

  def completed_stock
    @po_requests = ApplyDatatableParams.to(PoRequest.all.completed_stock_po.order(id: :desc), params)
    authorize_acl @po_requests

    respond_to do |format|
      format.json {render 'index'}
      format.html {render 'index'}
    end
  end

  def new_purchase_order
    @warehouse = @po_request.bill_to.name
    @modal_show = false
    if @po_request.bill_to.series_code.present?
      date = Date.today
      year = date.year
      year = year - 1 if date.month < 4
      series_name = @po_request.bill_to.series_code + ' ' + year.to_s
      @series = Series.where(document_type: 'Purchase Order', series_name: series_name)
      if !@series.present?
        @modal_show = true
      end
    else
      @modal_show = true
    end
    authorize_acl @po_request
  end

  def create_purchase_order
    authorize_acl @po_request
    service = Services::Overseers::PurchaseOrders::CreatePurchaseOrder.new(@po_request, params.merge(overseer:
                                                                                                         current_overseer), @notification)
    purchase_order = service.create
    if purchase_order.present?
      redirect_to overseers_inquiry_purchase_order_path(purchase_order.inquiry.to_param, purchase_order.to_param)
    else
      redirect_to overseers_purchase_orders_path
    end
  end

  def reject_purchase_order_modal
    authorize_acl @po_request
    respond_to do |format|
      format.html { render partial: 'reject_purchase_order'}
    end
  end

  def rejected_purchase_order
    @po_request.assign_attributes(po_request_params.merge(overseer: current_overseer))
    authorize_acl @po_request
    status = Services::Overseers::PurchaseOrders::RejectPurchaseOrder.new(params, @po_request).call
    if status
      # redirect_to overseers_po_request_path(@po_request), notice: flash_message(@po_request, action_name)
      render json: {sucess: 'Successfully updated ', url: pending_and_rejected_overseers_po_requests_path }, status: 200
    else
      render json: {error: @po_request.errors }, status: 500
    end
  end

  def manager_amended
    Services::Overseers::PurchaseOrders::CreatePurchaseOrder.new(@po_request, params.merge(overseer: current_overseer), @notification).update
    redirect_to overseers_inquiry_purchase_order_path(@po_request.inquiry.to_param, @po_request.purchase_order.to_param)
    authorize_acl @po_request
  end

  def product_resync_inventory
    service = Services::Resources::Products::UpdateInventory.new([@product])
    service.resync
    respond_to do |format|
      format.html {render partial: 'product_resync_inventory', locals: {product: @product}}
    end
    authorize_acl :po_request
  end

  def stock_amend_requests
    @po_requests = ApplyDatatableParams.to(PoRequest.all.stock_amend_request.order(id: :desc), params)
    authorize_acl @po_requests

    respond_to do |format|
      format.json {render 'index'}
      format.html {render 'index'}
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
          :transport_mode,
          :delivery_type,
          :commercial_terms_and_conditions,
          comments_attributes: [:id, :message, :created_by_id, :updated_by_id],
          rows_attributes: [:id, :sales_order_row_id, :product_id, :_destroy, :status, :quantity, :tax_code_id, :tax_rate_id, :measurement_unit_id,:brand_id, :discount_percentage, :unit_price, :lead_time, :converted_unit_selling_price, :product_unit_selling_price, :conversion],
          attachments: []
      )
    end

    def set_po_request
      @po_request = PoRequest.find(params[:id])
    end

    def set_product
      @product = Product.find(params[:product_id])
    end
end
