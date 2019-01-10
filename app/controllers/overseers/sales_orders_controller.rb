class Overseers::SalesOrdersController < Overseers::BaseController
  before_action :set_sales_order, only: [ :resync]
  def pending
    authorize :sales_order

    respond_to do |format|
      format.html { render 'pending' }
      format.json do
        service = Services::Overseers::Finders::PendingSalesOrders.new(params, current_overseer,paginate: false)
        service.call

        @indexed_sales_orders = service.indexed_records
        @sales_orders = service.records.try(:reverse)

        status_service = Services::Overseers::Statuses::GetSummaryStatusBuckets.new(@indexed_sales_orders, SalesOrder)
        status_service.call

        @statuses = status_service.indexed_statuses

        render 'pending'
      end
    end
  end

  def export_all
    authorize :sales_order
    service = Services::Overseers::Exporters::SalesOrdersExporter.new
    service.call

    redirect_to url_for(Export.sales_orders.last.report)
  end

  def export_rows
    authorize :sales_order
    service = Services::Overseers::Exporters::SalesOrderRowsExporter.new
    service.call

    redirect_to url_for(Export.sales_order_rows.last.report)
  end

  def export_for_logistics
    authorize :sales_order
    service = Services::Overseers::Exporters::SalesOrdersLogisticsExporter.new
    service.call

    redirect_to url_for(Export.sales_order_logistics.last.report)
  end

  def export_for_sap
    authorize :sales_order
    service = Services::Overseers::Exporters::SalesOrdersSapExporter.new
    service.call

    redirect_to url_for(Export.sales_order_sap.last.report)
  end

  def index
    authorize :sales_order
    respond_to do |format|
      format.html {}
      format.json do
        service = Services::Overseers::Finders::SalesOrders.new(params, current_overseer)
        service.call

        @indexed_sales_orders = service.indexed_records
        @sales_orders = service.records.try(:reverse)

        status_service = Services::Overseers::Statuses::GetSummaryStatusBuckets.new(@indexed_sales_orders, SalesOrder)
        status_service.call

        @statuses = status_service.indexed_statuses
      end
    end
  end

  def not_invoiced
    authorize :sales_order
    respond_to do |format|
      format.html {render 'not_invoiced' }
      format.json do
        service = Services::Overseers::Finders::SalesOrders.new(params, current_overseer)
        service.call

        @indexed_sales_orders = service.indexed_records
        @sales_orders = service.records.try(:reverse)

        status_service = Services::Overseers::Statuses::GetSummaryStatusBuckets.new(@indexed_sales_orders, SalesOrder)
        status_service.call
        @total_values = status_service.indexed_total_values
        @statuses = status_service.indexed_statuses
      end
    end
  end

  def autocomplete
    service = Services::Overseers::Finders::SalesOrders.new(params.merge(page: 1))
    service.call

    @indexed_sales_orders = service.indexed_records
    @sales_orders = service.records.reverse

    authorize :sales_order
  end

  def drafts_pending
    authorize :sales_order

    sales_orders = SalesOrder.where.not(:sent_at => nil).where(:draft_uid => nil , :status => :'SAP Approval Pending').not_legacy
    respond_to do |format|
      format.html {}
      format.json do
        @drafts_pending_count = sales_orders.count
        @sales_orders = ApplyDatatableParams.to(sales_orders, params)
        render 'drafts_pending'
      end
    end
  end

  def resync
    authorize :sales_order
    if @sales_order.save_and_sync
      redirect_to drafts_pending_overseers_sales_orders_path
    end
  end

  private

  def set_sales_order
    @sales_order = SalesOrder.find(params[:id])
  end
end
