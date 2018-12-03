class Overseers::Companies::SalesInvoicesController < Overseers::Companies::BaseController
  def index
    @sales_invoices = ApplyDatatableParams.to(@company.invoices, params)
    authorize @sales_invoices
  end
end
