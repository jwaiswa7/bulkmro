class Overseers::Inquiries::SalesInvoicesController < Overseers::Inquiries::BaseController
  before_action :set_sales_invoice, only: [:show]

  def index
    @sales_invoices = @inquiry.invoices
    authorize @sales_invoices
  end

  def show
    # @sales_order = SalesOrder.find(params[:order_id])
    # @sales_invoice = SalesInvoice.create!(invoice_uid: params[:increment_id], sales_order: @sales_order, request_payload: params)
    # @invoice = @sales_invoice.request_payload.deep_symbolize_keys
    # @invoice[:ItemLine].each do |item|
    #   @sales_order.rows.each do |row|
    #     if row.sales_quote_row.product.sku == item[:sku]
    #       item[:remote_name] = item[:name]
    #       item[:name] = row.sales_quote_row.to_bp_catalog_s
    #       item[:uom] = row.sales_quote_row.product.measurement_unit.name
    #       item[:hsn] =  @sales_order.sales_quote.is_sez ? row.tax_code.chapter : row.tax_code.code
    #       item[:tax_rate] = row.tax_code.tax_percentage
    #     end
    #   end
    # end
    # @sales_invoice.update_attributes(request_payload: @invoice)

    authorize @sales_invoice
    @metadata = @sales_invoice.metadata

    respond_to do |format|
      format.html {}
      format.pdf do
        render_pdf_for @sales_invoice
      end
    end
  end

  private

  def set_sales_invoice
    @sales_invoice = @inquiry.invoices.find(params[:id])
  end

end

