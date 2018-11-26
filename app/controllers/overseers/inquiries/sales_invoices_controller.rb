class Overseers::Inquiries::SalesInvoicesController < Overseers::Inquiries::BaseController
  before_action :set_sales_invoice, only: [:show, :triplicate, :duplicate, :edit_mis_date, :update_mis_date]

  def index
    @sales_invoices = @inquiry.invoices
    authorize @sales_invoices
  end

  def show
    authorize @sales_invoice
    @metadata = @sales_invoice.metadata.deep_symbolize_keys

    respond_to do |format|
      format.html {}
      format.pdf do
        render_pdf_for @sales_invoice
      end
    end
  end

  def duplicate
    authorize @sales_invoice, :show?
    @metadata = @sales_invoice.metadata.deep_symbolize_keys

    respond_to do |format|
      format.html {}
      format.pdf do
        render_pdf_for @sales_invoice, {duplicate: true}
      end
    end
  end

  def triplicate
    authorize @sales_invoice, :show?
    @metadata = @sales_invoice.metadata.deep_symbolize_keys

    respond_to do |format|
      format.html {}
      format.pdf do
        render_pdf_for @sales_invoice, {triplicate: true}
      end
    end
  end

  def edit_mis_date
    if @sales_invoice.mis_date.blank?
      @sales_invoice.mis_date = @sales_invoice.created_at.strftime("%d-%b-%Y")
    end

    authorize @sales_invoice
  end

  def update_mis_date
    @sales_invoice.assign_attributes(sales_invoice_params)
    authorize @sales_invoice

    if @sales_invoice.save
      redirect_to overseers_inquiry_sales_invoices_path(@inquiry), notice: flash_message(@inquiry, action_name)
    else
      render 'edit'
    end
  end

  private

  def save
    @sales_invoice.save
  end


  def set_sales_invoice
    @sales_invoice = @inquiry.invoices.find(params[:id])
  end

  def sales_invoice_params
    params.require(:sales_invoice).permit(:mis_date)
  end
end

