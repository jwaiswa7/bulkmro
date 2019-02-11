class Overseers::PoRequestsController < Overseers::BaseController
  before_action :set_po_request, only: [:show, :edit, :update]

  def pending_and_rejected
    @po_requests = ApplyDatatableParams.to(scope_by(current_overseer).pending_and_rejected.order(id: :desc), params)
    authorize @po_requests

    respond_to do |format|
      format.json {render 'index'}
      format.html {render 'index'}
    end
  end

  def cancelled
    @po_requests = ApplyDatatableParams.to(scope_by(current_overseer).cancelled.order(id: :desc), params)
    authorize @po_requests

    respond_to do |format|
      format.json {render 'index'}
      format.html {render 'index'}
    end
  end

  def amended
    @po_requests = ApplyDatatableParams.to(scope_by(current_overseer).amended.order(id: :desc), params)
    authorize @po_requests

    respond_to do |format|
      format.json {render 'index'}
      format.html {render 'index'}
    end
  end

  def scope_by(overseer)
    PoRequest.all.joins(:inquiry).where('inquiries.inside_sales_owner_id = ? OR inquiries.outside_sales_owner_id = ? OR po_requests.created_by_id = ?', overseer.id, overseer.id, overseer.id)
  end

  def index
    @po_requests = ApplyDatatableParams.to(scope_by(current_overseer).handled.order(id: :desc), params)
    authorize @po_requests
  end

  def show
    authorize @po_request
  end

  def new
    if params[:sales_order_id].present?
      @sales_order = SalesOrder.find(params[:sales_order_id])
      @po_request = PoRequest.new(:overseer => current_overseer, :sales_order => @sales_order, :inquiry => @sales_order.inquiry)
      @sales_order.rows.each do |sales_order_row|
        @po_request.rows.where(:sales_order_row => sales_order_row).first_or_initialize
      end
      service = Services::Overseers::CompanyReviews::CreateCompanyReview.new(@sales_order,current_overseer)
      @company_reviews = service.call

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
        @po_request_comment = PoRequestComment.new(:message => "PO Request submitted.", :po_request => @po_request, :overseer => current_overseer)
        @po_request_comment.save!
      end

      redirect_to overseers_po_request_path(@po_request), notice: flash_message(@po_request, action_name)
    else
      render 'new'
    end
  end

  def edit
    authorize @po_request
  end

  def update

    @po_request.assign_attributes(po_request_params.merge(overseer: current_overseer))
    authorize @po_request
    if @po_request.valid?
      # todo allow only in case of zero form errors
      @po_request.status = "PO Created" if @po_request.purchase_order.present? && @po_request.status == "Requested"
      @po_request.status = "Requested" if @po_request.status == "Rejected" && policy(@po_request).is_manager_or_sales?
      ActiveRecord::Base.transaction do if @po_request.status_changed?
          if @po_request.status == "Cancelled"
            @po_request_comment = PoRequestComment.new(:message => "Status Changed: #{@po_request.status} PO Request for Purchase Order number #{@po_request.purchase_order.po_number} \r\n Cancellation Reason: #{@po_request.cancellation_reason}" , :po_request => @po_request, :overseer => current_overseer)
            @po_request.purchase_order = nil

            @po_request.payment_request.update!(status: :'Cancelled')
            @po_request.payment_request.comments.create!(:message => "Status Changed: #{@po_request.payment_request.status}; Po Request #{@po_request.id}: Cancelled", :payment_request => @po_request.payment_request, :overseer => current_overseer)

          elsif @po_request.status == "Rejected"
            @po_request_comment = PoRequestComment.new(:message => "Status Changed: #{@po_request.status} \r\n Rejection Reason: #{@po_request.rejection_reason}" , :po_request => @po_request, :overseer => current_overseer)

          else
            @po_request_comment = PoRequestComment.new(:message => "Status Changed: #{@po_request.status}", :po_request => @po_request, :overseer => current_overseer)
          end
          @po_request.save!
          @po_request_comment.save!
        else
          @po_request.save!
        end
      end

      # create_payment_request = Services::Overseers::PaymentRequests::Create.new(@po_request)
      # create_payment_request.call

      redirect_to overseers_po_request_path(@po_request), notice: flash_message(@po_request, action_name)
    else
      render 'edit'
    end
  end

  def update_logistics_owner
    @po_requests = PoRequest.where(id: params[:po_requests])
    authorize @po_requests
    @po_requests.update_all(logistics_owner_id: params[:logistics_owner_id])
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
        :cancellation_reason,
        :rejection_reason,
        :rows_attributes => [:id, :sales_order_row_id,:product_id, :_destroy, :status, :quantity, :tax_code_id, :tax_rate_id, :discount_percentage, :unit_price, :lead_time],
        :comments_attributes => [:id, :message, :created_by_id, :updated_by_id],
        :attachments => []
    )
  end

  def set_po_request
    @po_request = PoRequest.find(params[:id])
  end
end