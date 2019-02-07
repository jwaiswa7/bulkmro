class Overseers::Inquiries::PoRequestsController < Overseers::Inquiries::BaseController
  before_action :set_po_request, only: [:show, :edit, :update]

  def index
    @po_requests = @inquiry.po_requests
    authorize @po_requests
  end

  def show
    authorize @po_request

  end

  def new
    @po_requests = @inquiry.po_requests.build
    @po_request_rows = @po_requests.rows.build
    authorize @po_requests
  end

  def edit
    authorize @po_request
  end

  def update
    @po_request.assign_attributes(po_request_params.merge(overseer: current_overseer))
    authorize @po_request
    if @po_request.valid?
      # todo allow only in case of zero form errors
       if @po_request.purchase_order.present? && @po_request.stock_status == "Stock Requested"
         @po_request.stock_status = "Stock Supplier PO Created"
         @po_request.approved_by = current_overseer
       end
      ActiveRecord::Base.transaction do
        if @po_request.stock_status_changed?
          if @po_request.stock_status == "Stock Rejected"
            @po_request_comment = PoRequestComment.new(:message => "Stock Status Changed: #{@po_request.stock_status} \r\n Rejection Reason: #{@po_request.rejection_reason}" , :po_request => @po_request, :overseer => current_overseer)

          else
            @po_request_comment = PoRequestComment.new(:message => "Stock Status Changed: #{@po_request.stock_status}", :po_request => @po_request, :overseer => current_overseer)
          end
          @po_request.save!
          @po_request_comment.save!
        else
          @po_request.save!
        end
      end

      create_payment_request = Services::Overseers::PaymentRequests::Create.new(@po_request)
      create_payment_request.call

      redirect_to overseers_inquiry_po_request_path(@po_request.inquiry, @po_request), notice: flash_message(@po_request, action_name)
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
        :payment_option_id,
        :status,
        :cancellation_reason,
        :rejection_reason,
        :stock_status,
        :requested_by_id,
        :approved_by_id,
        :supplier_id,
        :rows_attributes => [:id, :sales_order_row_id, :_destroy, :status, :quantity, :tax_code_id, :tax_rate_id, :brand, :product_id, :converted_unit_selling_price, :product_unit_selling_price,:conversion],
        :comments_attributes => [:id, :message, :created_by_id, :updated_by_id],
        :attachments => []
    )
  end

  def set_po_request
    @po_request = @inquiry.po_requests.find(params[:id])
  end
end

