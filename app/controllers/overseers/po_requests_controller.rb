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

        @so_products = @po_request.sales_order.rows
        @so_products .each do |so_product|
          @po_request.po_request_products.where(:sales_order_row => so_product).first_or_create! do |row|
            row.product = so_product.product
            row.quantity = so_product.quantity
            row.sales_quote_row = so_product.sales_quote_row
          end
        end
        @po_request.save
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

      redirect_to overseers_po_request_path(@po_request), notice: flash_message(@po_request, action_name)
    else
      redirect_to edit_overseers_po_request_path, notice: flash_message(@po_request, action_name)
    end
  end

  private

  def po_request_params
    params.require(:po_request).permit(
        :id,
        :inquiry_id,
        :sales_order_id,
        :purchase_order_number,
        :status,
        :po_request_products_attributes => [:id, :product, :sales_order_row, :sales_quote_row, :quantity],
        :comments_attributes => [:id, :message, :created_by_id],
        :attachments => []
    )
  end

  def set_po_request
    @po_request = PoRequest.find(params[:id])
  end
end