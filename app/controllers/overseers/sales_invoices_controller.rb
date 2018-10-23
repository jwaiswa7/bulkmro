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
    # start_at = Date.today - 1.day
    # end_at = Date.today


    respond_to do |format|
      format.html
      format.csv { send_data SalesInvoice.to_csv, filename: "sales-invoices-#{Date.today}.csv" }
    end
  end
end