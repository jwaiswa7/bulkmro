class Overseers::InvoiceRequestsController < Overseers::BaseController
  before_action :set_invoice_request, only: [:show, :edit, :update]

  def pending
    invoice_requests =
        if params[:status].present?
          @title = params[:status]
          InvoiceRequest.where(:status => params[:status])
        else
          InvoiceRequest.all
        end.order(id: :desc)

    @invoice_requests = ApplyDatatableParams.to(invoice_requests, params)
    authorize @invoice_requests

    respond_to do |format|
      format.json {render 'index'}
      format.html {render 'index'}
    end
  end

  def completed
    @invoice_requests = ApplyDatatableParams.to(InvoiceRequest.all.ar_invoice_generated.order(id: :desc), params)
    authorize @invoice_requests

    respond_to do |format|
      format.json {render 'index'}
      format.html {render 'index'}
    end
  end

  def index
    @invoice_requests = ApplyDatatableParams.to(InvoiceRequest.all.order(id: :desc), params)
    authorize @invoice_requests
  end

  def show
    authorize @invoice_request
  end

  def new
    if params[:sales_order_id].present?
      @sales_order = SalesOrder.find(params[:sales_order_id])
      @invoice_request = InvoiceRequest.new(:overseer => current_overseer, :sales_order => @sales_order, :inquiry => @sales_order.inquiry)
      authorize @invoice_request
    else
      redirect_to overseers_invoice_requests_path
    end
  end

  def create
    @invoice_request = InvoiceRequest.new(invoice_request_params.merge(overseer: current_overseer))
    authorize @invoice_request

    if @invoice_request.valid?
      ActiveRecord::Base.transaction do
        @invoice_request.save!
        @invoice_request_comment = InvoiceRequestComment.new(:message => "Invoice Request submitted.", :invoice_request => @invoice_request, :overseer => current_overseer)
        @invoice_request_comment.save!
      end

      redirect_to overseers_invoice_request_path(@invoice_request), notice: flash_message(@invoice_request, action_name)
    else
      render 'new'
    end
  end

  def edit
    authorize @invoice_request
  end

  def update
    @invoice_request.assign_attributes(invoice_request_params.merge(overseer: current_overseer))
    authorize @invoice_request

    if @invoice_request.valid?
      @invoice_request.auto_update_status
      ActiveRecord::Base.transaction do
        if @invoice_request.status_changed?
          @invoice_request_comment = InvoiceRequestComment.new(:message => "Status Changed: #{@invoice_request.status}", :invoice_request => @invoice_request, :overseer => current_overseer)
          @invoice_request.save!
          @invoice_request_comment.save!
        else
          @invoice_request.save!
        end
      end

      redirect_to overseers_invoice_request_path(@invoice_request), notice: flash_message(@invoice_request, action_name)
    else
      render 'edit'
    end
  end

  private

  def invoice_request_params
    params.require(:invoice_request).permit(
        :id,
        :inquiry_id,
        :sales_order_id,
        :grpo_number,
        :ap_invoice_number,
        :shipment_number,
        :ar_invoice_number,
        :purchase_order_id,
        :status,
        :comments_attributes => [:id, :message, :created_by_id],
        :attachments => []
    )
  end

  def set_invoice_request
    @invoice_request = InvoiceRequest.find(params[:id])
  end
end