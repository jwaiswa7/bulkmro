class Overseers::ArInvoicesController < Overseers::BaseController
  before_action :set_ar_invoice, only: [:show, :edit, :update, :destroy]

  # GET /ar_invoices
  # GET /ar_invoices.json
  def index
    authorize :ar_invoice
    if params[:status].present?
      base_filter = {
          base_filter_key: 'status'
      }
      if params[:status] == "pending"
        base_filter[:base_filter_value] = ArInvoice.statuses["AR Invoice requested"]
      elsif params[:status] == "cancelled"
        base_filter[:base_filter_value] = ArInvoice.statuses["Cancelled AR Invoice"]
      elsif params[:status] == "rejected"
        base_filter[:base_filter_value] = ArInvoice.statuses["AR Invoice Request Rejected"]
      elsif params[:status] == "completed"
        base_filter[:base_filter_value] = ArInvoice.statuses["Completed AR Invoice Request"]
      end
      service = Services::Overseers::Finders::ArInvoices.new(params.merge(base_filter), current_overseer)
    else
      @ar_invoices = ArInvoice.all
      service = Services::Overseers::Finders::ArInvoices.new(params)
    end
    service.call
    @indexed_ar_invoices = service.indexed_records
    @ar_invoices = service.records.try(:reverse)
  end

  # GET /ar_invoices/1
  # GET /ar_invoices/1.json
  def show
    authorize @ar_invoice
  end

  # GET /ar_invoices/new
  def new
    @sales_order = SalesOrder.where(:id => params[:so_id]).last
    @inward_dispatches = InwardDispatch.where(id: params[:ids])
    @ar_invoice = ArInvoice.new(overseer: current_overseer, sales_order: @sales_order, inquiry: @sales_order.inquiry)
    @inward_dispatches.each do |inward_dispatch|
      inward_dispatch.rows.each do |row|
        @ar_invoice.rows.build(quantity: row.delivered_quantity, inward_dispatch_row_id: row.id, sales_order_id: @sales_order.id)
      end
    end
    authorize @ar_invoice
  end

  # GET /ar_invoices/1/edit
  def edit
    authorize @ar_invoice
  end

  # POST /ar_invoices
  # POST /ar_invoices.json
  def create

    @ar_invoice = ArInvoice.new()

    @ar_invoice.assign_attributes(ar_invoice_params.merge(overseer: current_overseer))
    inward_dispatch_ids = params[:inward_dispatch_ids].first.split(',').map(&:to_i)
    authorize @ar_invoice
    respond_to do |format|
      if @ar_invoice.save!
        if inward_dispatch_ids.present?
          InwardDispatch.where(id: inward_dispatch_ids).update_all(ar_invoice_id: @ar_invoice.id)
        end
        format.html { redirect_to overseers_ar_invoice_path(@ar_invoice), notice: 'Ar invoice was successfully created.' }
        format.json { render :show, status: :created, location: @ar_invoice }
      else
        format.html { render :new }
        format.json { render json: @ar_invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ar_invoices/1
  # PATCH/PUT /ar_invoices/1.json
  def update
    authorize @ar_invoice
    respond_to do |format|
      if @ar_invoice.update(ar_invoice_params)
        format.html { redirect_to overseers_ar_invoice_path(@ar_invoice), notice: 'Ar invoice was successfully updated.' }
        format.json { render :show, status: :ok, location: @ar_invoice }
      else
        format.html { render :edit }
        format.json { render json: @ar_invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ar_invoices/1
  # DELETE /ar_invoices/1.json
  def destroy
    authorize @ar_invoice
    @ar_invoice.destroy
    respond_to do |format|
      format.html { redirect_to ar_invoices_url, notice: 'Ar invoice was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ar_invoice
      @ar_invoice = ArInvoice.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ar_invoice_params
      params.require(:ar_invoice).except(:action_name)
        .permit(
          :sales_order_id,
          :inquiry_id,
          :inward_dispatch_ids,
          :status,
          :cancellation_reason,
          :rejection_reason,
          :other_rejection_reason,
          :ar_invoice_number,
          :e_way,
          rows_attributes: [ :id, :inward_dispatch_row_id, :sales_order_id, :quantity ]
        )
    end
end
