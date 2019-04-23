class ArInvoicesController < ApplicationController
  before_action :set_ar_invoice, only: [:show, :edit, :update, :destroy]

  # GET /ar_invoices
  # GET /ar_invoices.json
  def index
    @ar_invoices = ArInvoice.all
  end

  # GET /ar_invoices/1
  # GET /ar_invoices/1.json
  def show
  end

  # GET /ar_invoices/new
  def new
    @ar_invoice = ArInvoice.new
  end

  # GET /ar_invoices/1/edit
  def edit
  end

  # POST /ar_invoices
  # POST /ar_invoices.json
  def create
    @ar_invoice = ArInvoice.new(ar_invoice_params)

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
    respond_to do |format|
      if @ar_invoice.update(ar_invoice_params)
        format.html { redirect_to @ar_invoice, notice: 'Ar invoice was successfully updated.' }
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
      params.fetch(:ar_invoice, {})
    end
end
