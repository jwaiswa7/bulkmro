class Overseers::Companies::SalesInvoicesController < Overseers::Companies::BaseController
  def index
    @sales_invoices = ApplyDatatableParams.to(@company.invoices, params.reject! { |k, v| k == 'company_id' })
    authorize @sales_invoices
  end

  def payment_collection
    @sales_invoices = ApplyDatatableParams.to(SalesInvoice.all, params.reject! { |k, v| k == 'company_id' })
    authorize @sales_invoices
  end
end
