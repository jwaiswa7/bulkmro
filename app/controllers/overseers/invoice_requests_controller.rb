class Overseers::InvoiceRequestsController < Overseers::BaseController
  before_action :set_invoice_request, only: [:show, :edit, :update, :reject_grpo]

  def pending
    invoice_requests =
        if params[:status].present?
          @status = params[:status]
          InvoiceRequest.where(status: params[:status])
        else
          InvoiceRequest.all
        end.order(id: :desc)

    @invoice_requests = ApplyDatatableParams.to(invoice_requests, params)
    authorize @invoice_requests

    respond_to do |format|
      format.json { render 'index' }
      format.html { render 'index' }
    end
  end

  def completed
    @invoice_requests = ApplyDatatableParams.to(InvoiceRequest.all.ar_invoice_generated.order(id: :desc), params)
    authorize @invoice_requests

    respond_to do |format|
      format.json { render 'index' }
      format.html { render 'index' }
    end
  end

  def index
    @invoice_requests = ApplyDatatableParams.to(InvoiceRequest.all.order(id: :desc), params)
    authorize @invoice_requests
    @statuses = @invoice_requests.pluck(:status)
  end

  def show
    authorize @invoice_request
    @order = @invoice_request.sales_order || @invoice_request.purchase_order
    service = Services::Overseers::CompanyReviews::CreateCompanyReview.new(@order, current_overseer, @invoice_request, 'Logistics')
    @company_reviews = service.call
    service = Services::Overseers::InvoiceRequests::FormProductsList.new(@invoice_request.material_pickup_requests.ids,  false)
    @products_list = service.call
  end

  def new
    if params[:sales_order_id].present?
      @sales_order = SalesOrder.find(params[:sales_order_id])
      @invoice_request = InvoiceRequest.new(overseer: current_overseer, sales_order: @sales_order, inquiry: @sales_order.inquiry)

      authorize @invoice_request
    elsif params[:purchase_order_id].present?
      @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
      @sales_order = @purchase_order.try(:po_request).try(:sales_order)
      @invoice_request = InvoiceRequest.new(overseer: current_overseer, purchase_order: @purchase_order, inquiry: @purchase_order.inquiry)
      @mpr_ids = params[:ids].present? ? params[:ids] : MaterialPickupRequest.decode_id(params[:mpr_id])

      authorize @invoice_request
      if params[:mpr_id] || params[:ids]
        if params[:mpr_id]
          @invoice_request.material_pickup_requests << MaterialPickupRequest.find(@mpr_ids)
        else
          @invoice_request.material_pickup_requests << MaterialPickupRequest.where(id: @mpr_ids)
        end
        service = Services::Overseers::InvoiceRequests::FormProductsList.new(@mpr_ids,  false)
      else
        service = Services::Overseers::InvoiceRequests::FormProductsList.new(@purchase_order,  true)
      end
      @products_list = service.call
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
        @invoice_request_comment = InvoiceRequestComment.new(message: 'Invoice Request submitted.', invoice_request: @invoice_request, overseer: current_overseer)
        @invoice_request_comment.save!
      end

      redirect_to edit_overseers_invoice_request_path(@invoice_request), notice: flash_message(@invoice_request, action_name)
    else
      render 'new'
    end
  end

  def edit
    authorize @invoice_request
    @order = @invoice_request.sales_order || @invoice_request.purchase_order
    service = Services::Overseers::CompanyReviews::CreateCompanyReview.new(@order, current_overseer, @invoice_request, 'Logistics')
    @company_reviews = service.call

    mpr_ids = @invoice_request.material_pickup_requests.map(&:id).join(', ')
    service = Services::Overseers::InvoiceRequests::FormProductsList.new(mpr_ids,  false)
    @products_list = service.call
  end

  def update
    @invoice_request.assign_attributes(invoice_request_params.merge(overseer: current_overseer))
    authorize @invoice_request
    if @invoice_request.valid?
      @invoice_request.update_status(@invoice_request.status)
      ActiveRecord::Base.transaction do
        if @invoice_request.status_changed?
          @invoice_request_comment = InvoiceRequestComment.new(message: "Status Changed: #{@invoice_request.status}", invoice_request: @invoice_request, overseer: current_overseer)
          if !['GRPO Request Rejected', 'AP Invoice Request Rejected'].include?(@invoice_request.status)
            @invoice_request.rejection_reason = nil
            @invoice_request.other_rejection_reason = nil
          else
            material_pickup_requests = @invoice_request.material_pickup_requests
            material_pickup_requests.each do |material_pickup_request|
              material_pickup_request.status = @invoice_request.status
              material_pickup_request.save
            end
          end
          @invoice_request.save!
          @invoice_request_comment.save!
        elsif @invoice_request.rejection_reason_changed? && @invoice_request.rejection_reason != 'Others'
          @invoice_request.other_rejection_reason = nil
          @invoice_request.save!
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
        :material_pickup_request_ids,
        :rejection_reason,
        :other_rejection_reason,
        :cancellation_reason,
        comments_attributes: [:id, :message, :created_by_id, :updated_by_id],
        attachments: [],

    )
  end

    def set_invoice_request
      @invoice_request = InvoiceRequest.find(params[:id])
    end
end
