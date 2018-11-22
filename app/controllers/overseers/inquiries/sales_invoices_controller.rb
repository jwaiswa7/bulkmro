class Overseers::Inquiries::SalesInvoicesController < Overseers::Inquiries::BaseController
  before_action :set_sales_invoice, only: [:show, :triplicate, :duplicate, :mis_date_edit, :update]

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

  def update
    @sales_invoice.assign_attributes(sales_invoice_params)
    authorize @sales_invoice

    callback_method = %w(save save_and_confirm).detect {|action| params[action]}

    if callback_method.present? && send(callback_method)
      redirect_to overseers_inquiry_sales_invoices_path(@inquiry), notice: flash_message(@inquiry, action_name) unless performed?
    else
      render 'edit'
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

  def mis_date_edit
    authorize @sales_invoice
  end

  private

  def save
    @sales_invoice.save
  end

  def save_and_confirm
    if @sales_invoice.save
      redirect_to new_confirmation_overseers_inquiry_sales_order_path(@inquiry, @sales_order), notice: flash_message(@inquiry, action_name)
    else
      false
    end
  end

  def set_sales_invoice
    @sales_invoice = @inquiry.invoices.find(params[:id])
  end

  def sales_invoice_params
    params.require(:sales_invoice).permit(:mis_date)
  end

end

