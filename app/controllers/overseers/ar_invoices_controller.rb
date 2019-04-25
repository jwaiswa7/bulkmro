class Overseers::ArInvoicesController < Overseers::BaseController
  before_action :set_ar_invoice, only: [:show, :edit, :update, :destroy]

  # GET /ar_invoices
  # GET /ar_invoices.json
  def index
    @ar_invoices = ArInvoice.all
    authorize @ar_invoices
  end

  # GET /ar_invoices/1
  # GET /ar_invoices/1.json
  def show
    authorize @ar_invoice
  end

  # GET /ar_invoices/new
  def new
    #@sales_order = SalesOrder.where(:id => params[:sales_order_id]).last
    @sales_order = SalesOrder.where(:id => 7317).last
    @ar_invoice = ArInvoice.new(overseer: current_overseer, sales_order: @sales_order, inquiry: @sales_order.inquiry)
    authorize @ar_invoice
  end

  # GET /ar_invoices/1/edit
  def edit
    authorize @ar_invoice
  end

  # POST /ar_invoices
  # POST /ar_invoices.json
  def create
    @ar_invoice = ArInvoice.new(ar_invoice_params)
    authorize @ar_invoice
    respond_to do |format|
      if @ar_invoice.save
        format.html { redirect_to @ar_invoice, notice: 'Ar invoice was successfully created.' }
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
      params.require(:ar_invoice).permit(
          :sales_order_id,
          :inquiry_id,
          :status,
          :cancellation_reason,
          :rejection_reason,
          :other_rejection_reason,
          :ar_invoice_number,
          :e_way
      )
    end
end
