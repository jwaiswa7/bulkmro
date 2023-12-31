class Overseers::Inquiries::SalesInvoicesController < Overseers::Inquiries::BaseController
  before_action :set_sales_invoice, only: [:show, :triplicate, :duplicate, :edit_mis_date, :update_mis_date, :make_zip, :relationship_map, :get_relationship_map_json]
  before_action :set_invoice_items, only: [:show, :duplicate, :triplicate, :make_zip]

  def index
    @sales_invoices = @inquiry.invoices
    authorize_acl @sales_invoices
  end

  def show
    authorize_acl @sales_invoice
    date = Date.parse(@sales_invoice.metadata['created_at'])
    year = date.year
    year = year - 1 if date.month < 4
    if @sales_invoice.inquiry.is_sez? || @sales_invoice.serialized_billing_address.country_code != 'IN'
      if @sales_invoice.metadata['created_at'].present? && Settings.accounts.try("arn_date_#{year}").present? && Date.parse(Settings.accounts.try("arn_date_#{year}")) <= Date.parse(@sales_invoice.metadata['created_at'])
        @arn_date = Date.parse(Settings.accounts.try("arn_date_#{year}"))
        @arn_number = Settings.accounts.try("arn_number_#{year}")
      else
        @arn_date = Date.parse(Settings.accounts.try('arn_date_2018'))
        @arn_number = Settings.accounts.try('arn_number_2018')
      end
    end
    @bill_from_warehouse = @sales_invoice.get_bill_from_warehouse
    respond_to do |format|
      format.html { render 'show' }
      format.pdf do
        render_pdf_for @sales_invoice, locals.merge!(pagination: false)
      end
    end
  end

  def duplicate
    authorize_acl @sales_invoice, 'show'
    @metadata = @sales_invoice.metadata.deep_symbolize_keys
    @bill_from_warehouse = @sales_invoice.get_bill_from_warehouse
    respond_to do |format|
      format.html {}
      format.pdf do
        render_pdf_for @sales_invoice, locals.merge!(duplicate: true, pagination: false)
      end
    end
  end

  def triplicate
    authorize_acl @sales_invoice, 'show'
    @metadata = @sales_invoice.metadata.deep_symbolize_keys
    @bill_from_warehouse = @sales_invoice.get_bill_from_warehouse

    respond_to do |format|
      format.html {}
      format.pdf do
        render_pdf_for @sales_invoice, locals.merge!(triplicate: true, pagination: false)
      end
    end
  end

  def make_zip
    authorize_acl @sales_invoice

    service = Services::Overseers::SalesInvoices::Zipped.new(@sales_invoice, locals.merge(pagination: false, bill_from_warehouse: @sales_invoice.get_bill_from_warehouse))
    zip = service.call

    send_data(zip, type: 'application/zip', filename: @sales_invoice.zipped_filename(include_extension: true))
  end

  def edit_mis_date
    if @sales_invoice.mis_date.blank?
      @sales_invoice.mis_date = @sales_invoice.created_at.strftime('%d-%b-%Y')
    end

    authorize_acl @sales_invoice
  end

  def update_mis_date
    @sales_invoice.assign_attributes(sales_invoice_params)
    authorize_acl @sales_invoice

    if @sales_invoice.save
      redirect_to overseers_inquiry_sales_invoices_path(@inquiry), notice: flash_message(@inquiry, action_name)
    else
      render 'edit'
    end
  end

  def relationship_map
    authorize_acl @sales_invoice
  end

  def get_relationship_map_json
    authorize_acl @sales_invoice
    inquiry_json = Services::Overseers::Inquiries::RelationshipMap.new(@sales_invoice.inquiry, [@sales_invoice.sales_order.sales_quote]).call
    render json: {data: inquiry_json}
  end

  private

    def save
      @sales_invoice.save
    end

    def set_sales_invoice
      @sales_invoice = @inquiry.invoices.find(params[:id])
      @locals = {stamp: false}
      if params[:stamp].present?
        @locals = {stamp: true}
      end
    end

    def set_invoice_items
      Resources::SalesInvoice.set_multiple_items([@sales_invoice.invoice_number])
    end

    def sales_invoice_params
      params.require(:sales_invoice).permit(:mis_date)
    end

    attr_accessor :locals
end
