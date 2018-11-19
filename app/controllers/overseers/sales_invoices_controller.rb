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

  def autocomplete
    @salesinvoice=ApplyParams.to(SalesInvoice.all, params)
    authorize @salesinvoice
  end

  def export_all
    authorize :sales_invoice
    service = Services::Overseers::Exporters::SalesInvoicesExporter.new

    respond_to do |format|
      format.html
      format.csv { send_data service.call, filename: service.filename }
    end
  end

  def export_rows
    authorize :sales_invoice
    service = Services::Overseers::Exporters::SalesInvoiceRowsExporter.new

    respond_to do |format|
      format.html
      format.csv { send_data service.call, filename: service.filename }
    end
  end

  def export_for_logistics
    authorize :sales_invoice
    service = Services::Overseers::Exporters::SalesInvoicesLogisticsExporter.new

    respond_to do |format|
      format.html
      format.csv { send_data service.call, filename: service.filename }
    end
  end

end