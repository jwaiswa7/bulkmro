class Overseers::ArInvoiceRequestsController < Overseers::BaseController
  before_action :set_ar_invoice_request, only: [:show, :edit, :update, :destroy, :cancel_ar_invoice, :render_cancellation_form, :download_eway_bill_format, :render_modal_form, :add_comment]

  # GET /ar_invoices
  # GET /ar_invoices.json
  def index
    authorize_acl :ar_invoice_request
    if params[:status].present?
      base_filter = {
          base_filter_key: 'status',
          base_filter_value: ArInvoiceRequest.statuses[params[:status]]
      }
      service = Services::Overseers::Finders::ArInvoiceRequests.new(params.merge(base_filter), current_overseer)
    else
      @ar_invoice_requests = ArInvoiceRequest.all
      service = Services::Overseers::Finders::ArInvoiceRequests.new(params, current_overseer)
    end
    service.call
    @indexed_ar_invoices = service.indexed_records
    @ar_invoice_requests = service.records.try(:reverse)
  end

  # GET /ar_invoices/1
  # GET /ar_invoices/1.json
  def show
    # @rows = @ar_invoice_request.sales_order.rows
    # @sales_order_row = @ar_invoice_request.sales_order.rows.includes(:product)
    authorize_acl @ar_invoice_request
  end

  # GET /ar_invoices/new
  def new
    @inward_dispatches = InwardDispatch.where(id: params[:ids])
    service = Services::Overseers::ArInvoiceRequests::New.new(params.merge(overseer: current_overseer), @inward_dispatches)
    @ar_invoice_request = service.call
    authorize_acl @ar_invoice_request
  end

  # GET /ar_invoices/1/edit
  def edit
    authorize_acl @ar_invoice_request
  end

  # POST /ar_invoices
  # POST /ar_invoices.json
  def create
    @ar_invoice_request = ArInvoiceRequest.new()
    @ar_invoice_request.assign_attributes(ar_invoice_request_params.merge(overseer: current_overseer))
    @ar_invoice_request.inward_dispatch_ids = params['inward_dispatch_ids'].split(',').map {|x| x.to_i}
    @ar_invoice_request.update_status(@ar_invoice_request.status)
    authorize_acl @ar_invoice_request
    respond_to do |format|
      if @ar_invoice_request.save
        service = Services::Overseers::ArInvoiceRequests::Update.new(@ar_invoice_request, current_overseer)
        service.call
        format.html { redirect_to overseers_ar_invoice_request_path(@ar_invoice_request), notice: 'AR invoice was successfully created.' }
        format.json { render :show, status: :created, location: @ar_invoice_request }
      else
        format.html { render :new }
        format.json { render json: @ar_invoice_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ar_invoices/1
  # PATCH/PUT /ar_invoices/1.json
  def update
    authorize_acl @ar_invoice_request
    @ar_invoice_request.assign_attributes(ar_invoice_request_params.merge(overseer: current_overseer))
    @ar_invoice_request.update_status(@ar_invoice_request.status)
    respond_to do |format|
      if @ar_invoice_request.valid?
        service = Services::Overseers::ArInvoiceRequests::Update.new(@ar_invoice_request, current_overseer)
        service.call
        format.html { redirect_to overseers_ar_invoice_request_path(@ar_invoice_request), notice: 'AR invoice was successfully updated.' }
        format.json { render :show, status: :ok, location: @ar_invoice_request }
      else
        format.html { render :edit }
        format.json { render json: @ar_invoice_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ar_invoices/1
  # DELETE /ar_invoices/1.json
  def destroy
    authorize_acl @ar_invoice_request
    @ar_invoice_request.destroy
    respond_to do |format|
      format.html { redirect_to ar_invoice_requests_url, notice: 'AR invoice was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def cancel_ar_invoice
    @ar_invoice_request.assign_attributes(ar_invoice_request_params.merge(overseer: current_overseer))
    authorize_acl @ar_invoice_request
    @ar_invoice_request.update_status(@ar_invoice_request.status)
    if @ar_invoice_request.valid?
      @ar_invoice_request.save
      render json: {sucess: 'Successfully updated '}, status: 200
    else
      render json: {error: @ar_invoice_request.errors}, status: 500
      render json: {error: @ar_invoice_request.errors}, status: 500
    end
  end

  def render_cancellation_form
    authorize_acl @ar_invoice_request
    respond_to do |format|
      format.html {render partial: 'cancel_ar_invoice', locals: {status: params[:status]}}
    end
  end

  def download_eway_bill_format
    authorize_acl @ar_invoice_request
    @sales_order = @ar_invoice_request.sales_order
    @inquiry = @ar_invoice_request.inquiry
    @ar_invoice_rows = @ar_invoice_request.rows
    respond_to do |format|
      format.xlsx do
        response.headers['Content-Disposition'] = 'attachment; filename="' + ['Eway bill Excel Template', 'xlsx'].join('.') + '"'
      end
    end
  end

  def render_modal_form
    authorize_acl @ar_invoice_request
    respond_to do |format|
      if params[:title] == 'Comment'
        format.html {render partial: 'shared/layouts/add_comment', locals: {obj: @ar_invoice_request, url: add_comment_overseers_ar_invoice_request_path(@ar_invoice_request), view_more: overseers_ar_invoice_request_path(@ar_invoice_request)}}
      end
    end
  end

  def add_comment
    @ar_invoice_request.assign_attributes(ar_invoice_request_params.merge(overseer: current_overseer))
    authorize_acl @ar_invoice_request
    if @ar_invoice_request.valid?
      if params['ar_invoice_request']['comments_attributes']['0']['message'].present?
        ActiveRecord::Base.transaction do
          @ar_invoice_request.save!
          @ar_invoice_request_comment = ArInvoiceRequestComment.new(message: '', ar_invoice_request: @ar_invoice_request, overseer: current_overseer)
        end
        render json: {success: 1, message: 'Successfully updated '}, status: 200
      else
        render json: {error: {base: 'Field cannot be blank!'}}, status: 500
      end
    else
      render json: {error: @ar_invoice_request.errors}, status: 500
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ar_invoice_request
      @ar_invoice_request = ArInvoiceRequest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ar_invoice_request_params
      params.require(:ar_invoice_request).except(:action_name)
        .permit(
          :sales_order_id,
          :inquiry_id,
          :status,
          :cancellation_reason,
          :rejection_reason,
          :other_rejection_reason,
          :other_cancellation_reason,
          :sales_invoice_id,
          :e_way,
          :inward_dispatch_ids,
          rows_attributes: [ :id, :inward_dispatch_row_id, :sales_order_id, :quantity, :delivered_quantity, :_destroy, :product_id, :sales_order_row_id ],
          comments_attributes: [:id, :message, :created_by_id, :updated_by_id],
          )
    end
end
