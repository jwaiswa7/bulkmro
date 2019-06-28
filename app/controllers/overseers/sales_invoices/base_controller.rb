class Overseers::SalesInvoices::BaseController < Overseers::BaseController
  before_action :set_sales_invoice

  private
    def set_sales_invoice
      @sales_invoice = SalesInvoice.find(params[:sales_invoice_id])
    end
end
