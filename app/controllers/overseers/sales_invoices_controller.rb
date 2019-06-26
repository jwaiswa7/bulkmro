class Overseers::SalesInvoicesController < Overseers::BaseController
  before_action :set_invoice, only: [:edit_pod, :update_pod]

  def index
    authorize_acl :sales_invoice

    respond_to do |format|
      format.html {
        service = Services::Overseers::SalesInvoices::ProofOfDeliverySummary.new(params, current_overseer)
        service.call

        @invoice_over_month = service.invoice_over_month
        @regular_pod_over_month = service.regular_pod_over_month
        @route_through_pod_over_month = service.route_through_pod_over_month
        @pod_over_month = @regular_pod_over_month.merge(@route_through_pod_over_month) { |key, regular_value, route_through_value| regular_value['doc_count'] + route_through_value['doc_count']}
      }
      format.json do
        service = Services::Overseers::Finders::SalesInvoices.new(params, current_overseer)
        service.call
        @indexed_sales_invoices = service.indexed_records
        @sales_invoices = service.records
        status_service = Services::Overseers::Statuses::GetSummaryStatusBuckets.new(@indexed_sales_invoices, SalesInvoice)
        status_service.call
        @total_values = status_service.indexed_total_values
        @statuses = status_service.indexed_statuses
      end
    end
  end

  def edit_pod
    authorize_acl @invoice
    if !@invoice.pod_rows.present?
      @invoice.pod_rows.build
    end
  end

  def update_pod
    authorize_acl @invoice
    @invoice.assign_attributes(invoice_params)
    if @invoice.save
      redirect_to edit_pod_overseers_sales_invoice_path, notice: flash_message(@invoice, action_name)
    end
  end

  def autocomplete
    @sales_invoices = ApplyParams.to(SalesInvoice.all, params)
    authorize_acl @sales_invoices
  end

  def export_all
    authorize_acl :sales_invoice
    service = Services::Overseers::Exporters::SalesInvoicesExporter.new([], current_overseer, [])
    service.call

    redirect_to url_for(Export.sales_invoices.not_filtered.last.report)
  end

  def export_filtered_records
    authorize_acl :sales_invoice
    service = Services::Overseers::Finders::SalesInvoices.new(params, current_overseer, paginate: false)
    service.call

    export_service = Services::Overseers::Exporters::SalesInvoicesExporter.new([], current_overseer, service.records)
    export_service.call
  end

  def export_rows
    authorize_acl :sales_invoice
    service = Services::Overseers::Exporters::SalesInvoiceRowsExporter.new
    service.call

    redirect_to url_for(Export.sales_invoice_rows.last.report)
  end

  def export_for_logistics
    authorize_acl :sales_invoice
    service = Services::Overseers::Exporters::SalesInvoicesLogisticsExporter.new
    service.call

    redirect_to url_for(Export.sales_invoice_logistics.last.report)
  end

  def autocomplete
    sales_invoices = SalesInvoice.all
    if params[:inquiry_id].present?
      sales_invoices = SalesInvoice.joins(:inquiry).where(inquiries: {id: params[:inquiry_id]})
    end
    @sales_invoices = ApplyParams.to(sales_invoices, params)

    authorize :sales_invoice
  end

  private

    def set_invoice
      @invoice ||= SalesInvoice.find(params[:id])
    end

    def invoice_params
      params.require(:sales_invoice).permit(

        :delivery_date,
        :delivery_completed,
        pod_rows_attributes: [
            :id,
            :delivery_date,
            :sales_invoice_id,
            :_destroy,
            attachments: []
        ]
      )
    end
end
