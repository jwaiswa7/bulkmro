class Overseers::Inquiries::SalesInvoicesController < Overseers::Inquiries::BaseController
  before_action :set_sales_invoice, only: [:show, :triplicate, :duplicate, :edit_mis_date, :update_mis_date, :make_zip, :relationship_map, :get_relationship_map_json]
  before_action :set_invoice_items, only: [:show, :duplicate, :triplicate, :make_zip]

  def index
    @sales_invoices = @inquiry.invoices
    authorize @sales_invoices
  end

  def show
    authorize @sales_invoice
    @metadata = @sales_invoice.metadata.deep_symbolize_keys


    respond_to do |format|
      format.html { render 'show' }
      format.pdf do
        render_pdf_for @sales_invoice, locals
      end
    end
  end

  def duplicate
    authorize @sales_invoice, :show?
    @metadata = @sales_invoice.metadata.deep_symbolize_keys
    locals.merge!(duplicate: true)
    respond_to do |format|
      format.html { }
      format.pdf do
        render_pdf_for @sales_invoice, locals
      end
    end
  end

  def triplicate
    authorize @sales_invoice, :show?
    @metadata = @sales_invoice.metadata.deep_symbolize_keys
    locals.merge!(triplicate: true)
    respond_to do |format|
      format.html { }
      format.pdf do
        render_pdf_for @sales_invoice, locals
      end
    end
  end

  def make_zip
    authorize @sales_invoice

    service = Services::Overseers::SalesInvoices::Zipped.new(@sales_invoice, locals)
    zip = service.call

    send_data(zip, type: 'application/zip', filename: @sales_invoice.zipped_filename(include_extension: true))
  end

  def edit_mis_date
    if @sales_invoice.mis_date.blank?
      @sales_invoice.mis_date = @sales_invoice.created_at.strftime('%d-%b-%Y')
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

  def relationship_map
    authorize @sales_invoice
  end

  def get_relationship_map_json
    authorize @sales_invoice
    inquiry_json = Services::Overseers::Inquiries::RelationshipMap.new(@sales_invoice.inquiry, [@sales_invoice.sales_order.sales_quote]).call
    render json: {data: inquiry_json}
  end
  private

    def save
      @sales_invoice.save
    end

    def set_sales_invoice
      @sales_invoice = @inquiry.invoices.find(params[:id])
      @locals = { stamp: false }
      if params[:stamp].present?
        @locals = { stamp: true }
      end
    end

    def set_invoice_items
      Resources::SalesInvoice.set_multiple_items([@sales_invoice.invoice_number])
    end

    def sales_invoice_params
      params.require(:sales_invoice).permit(:mis_date)
    end


    def email_message_params
    params.require(:email_message).permit(
        :subject,
        :body,
        :to,
        :cc,
        :bcc,
        files: []
    )
    end

    attr_accessor :locals
end
