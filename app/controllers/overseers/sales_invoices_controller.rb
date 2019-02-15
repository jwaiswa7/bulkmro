class Overseers::SalesInvoicesController < Overseers::BaseController
  before_action :set_invoice, only: [:edit_pod, :update_pod]

  def index
    authorize :sales_invoice

    respond_to do |format|
      format.html { }
      format.json do
        service = Services::Overseers::Finders::SalesInvoices.new(params, current_overseer)
        service.call
        @indexed_sales_invoices = service.indexed_records
        @sales_invoices = service.records.try(:reverse)

        status_service = Services::Overseers::Statuses::GetSummaryStatusBuckets.new(@indexed_sales_invoices, SalesInvoice)
        status_service.call
        @total_values = status_service.indexed_total_values
        @statuses = status_service.indexed_statuses
      end
    end
  end

  def edit_pod
    authorize @invoice
  end

  def update_pod
    authorize @invoice
    @invoice.assign_attributes(invoice_params)

    if @invoice.save
      redirect_to edit_pod_overseers_sales_invoice_path, notice: flash_message(@invoice, action_name)
    end
  end

  def autocomplete
    @sales_invoices = ApplyParams.to(SalesInvoice.all, params)
    authorize @sales_invoices
  end

  def export_all
    authorize :sales_invoice
    service = Services::Overseers::Exporters::SalesInvoicesExporter.new(headers)
    self.response_body = service.call
    # Set the status to success
    response.status = 200
  end

  def export_rows
    authorize :sales_invoice
    service = Services::Overseers::Exporters::SalesInvoiceRowsExporter.new(headers)
    self.response_body = service.call
    # Set the status to success
    response.status = 200
  end

  def export_for_logistics
    authorize :sales_invoice
    service = Services::Overseers::Exporters::SalesInvoicesLogisticsExporter.new(headers)
    self.response_body = service.call
    # Set the status to success
    response.status = 200
  end

  private

    def set_invoice
      @invoice ||= SalesInvoice.find(params[:id])
    end

    def invoice_params
      params.require(:sales_invoice).permit(
        :pod_attachment,
          :delivery_date
      )
    end
end
