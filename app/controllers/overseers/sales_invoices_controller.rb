class Overseers::SalesInvoicesController < Overseers::BaseController

  def index
    authorize :sales_invoice

    respond_to do |format|
      format.html {}
      format.json do
        service = Services::Overseers::Finders::SalesInvoices.new(params, current_overseer)
        service.call
        @indexed_sales_invoices = service.indexed_records
        @sales_invoices = service.records.try(:reverse)
      end
    end
  end

  def export_sheet
    # TODO: Custome Datepicker to generate Sales Invoice report
    authorize :sales_invoice
    start_at = 'Fri, 19 Oct 2018'.to_date
    end_at = Date.today

    respond_to do |format|
      format.html
      format.csv { send_data SalesInvoice.to_csv, filename: "sales-invoices-#{start_at}-#{end_at}.csv" }
    end
  end
end