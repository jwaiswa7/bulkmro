class Overseers::PoRequestsController < Overseers::BaseController
  before_action :set_po_request, only: [:show, :edit, :update]

  def pending
    @po_requests = ApplyDatatableParams.to(PoRequest.all.pending.order(id: :desc), params)
    authorize @po_requests

    respond_to do |format|
      format.json {render 'index'}
      format.html {render 'index'}
    end
  end

  def index
    @po_requests = ApplyDatatableParams.to(PoRequest.all.handled.order(id: :desc), params)
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
      ActiveRecord::Base.transaction do
        if @po_request.status_changed?
          @po_request_comment = PoRequestComment.new(:message => "Status Changed: #{@po_request.status}", :po_request => @po_request, :overseer => current_overseer)
          @po_request.save!
          @po_request_comment.save!
        else
          @po_request.save!
        end
      end

      create_payment_request = Services::Overseers::PaymentRequests::Create.new(@po_request)
      create_payment_request.call

      redirect_to overseers_po_request_path(@po_request), notice: flash_message(@po_request, action_name)
    else
      render 'edit'
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
        :status,
        :rows_attributes => [:id, :sales_order_row_id, :_destroy],
        :comments_attributes => [:id, :message, :created_by_id],
        :attachments => []
    )
  end

  def set_po_request
    @po_request = PoRequest.find(params[:id])
  end
end