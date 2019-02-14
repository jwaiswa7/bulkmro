

class Overseers::Companies::SalesInvoicesController < Overseers::Companies::BaseController
  def index
    @sales_invoices = ApplyDatatableParams.to(@company.invoices, params.reject! { |k, v| k == 'company_id' })
    authorize @sales_invoices
  end
end
