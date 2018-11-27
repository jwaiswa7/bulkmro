class Overseers::SalesInvoicesController < Overseers::BaseController
  before_action :set_invoice, only: [:add_pod, :update_pod]

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

  def add_pod
    authorize @invoice
  end

  def update_pod
    authorize @invoice
    @invoice.assign_attributes(invoice_params)

    if @invoice.save
      redirect_to add_pod_overseers_sales_invoice_path, notice: flash_message(@invoice, action_name)
    end
  end

  def export_all
    authorize :sales_invoice
    service = Services::Overseers::Exporters::SalesInvoicesExporter.new

    respond_to do |format|
      format.html
      format.csv {send_data service.call, filename: service.filename}
    end
  end

  def export_rows
    authorize :sales_invoice
    service = Services::Overseers::Exporters::SalesInvoiceRowsExporter.new

    respond_to do |format|
      format.html
      format.csv {send_data service.call, filename: service.filename}
    end
  end

  def export_for_logistics
    authorize :sales_invoice
    service = Services::Overseers::Exporters::SalesInvoicesLogisticsExporter.new

    respond_to do |format|
      format.html
      format.csv {send_data service.call, filename: service.filename}
    end
  end

  private

  def set_invoice
    @invoice ||= SalesInvoice.find(params[:id])
  end

  def invoice_params
    params.require(:sales_invoice).permit(
        :pod_attachment,
        :pod_date
    )
  end

end