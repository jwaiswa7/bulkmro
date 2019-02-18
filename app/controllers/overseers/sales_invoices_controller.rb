# frozen_string_literal: true

class Overseers::SalesInvoicesController < Overseers::BaseController
  before_action :set_invoice, only: %i[edit_pod update_pod]

  def index
    authorize :sales_invoice

    respond_to do |format|
      format.html { }
      format.json do
        service = Services::Overseers::Finders::SalesInvoices.new(params, current_overseer, paginate: false)
        service.call

        per = (params[:per] || params[:length] || 20).to_i
        page = params[:page] || ((params[:start] || 20).to_i / per + 1)

        @indexed_sales_invoices = service.indexed_records.per(per).page(page)
        @sales_invoices = service.records.page(page).per(per).try(:reverse)

        if SalesInvoice.count != @indexed_sales_invoices.total_count
          status_records = service.records.try(:reverse)
          @statuses = status_records.pluck(:status)
        else
          @statuses = SalesInvoice.all.pluck(:status)
        end
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
    service = Services::Overseers::Exporters::SalesInvoicesExporter.new
    service.call

    redirect_to url_for(Export.sales_invoices.last.report)
  end

  def export_rows
    authorize :sales_invoice
    service = Services::Overseers::Exporters::SalesInvoiceRowsExporter.new
    service.call

    redirect_to url_for(Export.sales_invoice_rows.last.report)
  end

  def export_for_logistics
    authorize :sales_invoice
    service = Services::Overseers::Exporters::SalesInvoicesLogisticsExporter.new
    service.call

    redirect_to url_for(Export.sales_invoice_logistics.last.report)
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
