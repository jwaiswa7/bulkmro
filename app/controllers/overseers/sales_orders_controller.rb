class Overseers::SalesOrdersController < Overseers::BaseController
  before_action :set_sales_order, only: [ :resync, :new_purchase_orders_requests, :create_purchase_orders_requests]
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

        @total_values = status_service.indexed_total_values
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

        status_service = Services::Overseers::Statuses::GetSummaryStatusBuckets.new(@indexed_sales_orders, SalesOrder,remote_status:true)
        status_service.call

        @total_values = status_service.indexed_total_values
        @statuses = status_service.indexed_statuses
      end
    end
  end

  def not_invoiced
    authorize :sales_order
    respond_to do |format|
      format.html {render 'not_invoiced' }
      format.json do
        service = Services::Overseers::Finders::NotInvoicedSalesOrders.new(params, current_overseer)
        service.call

        @indexed_sales_orders = service.indexed_records
        @sales_orders = service.records.try(:reverse)

        status_service = Services::Overseers::Statuses::GetSummaryStatusBuckets.new(@indexed_sales_orders, SalesOrder,remote_status:true)
        status_service.call

        @total_values = status_service.indexed_total_values
        @statuses = status_service.indexed_statuses
        @statuses_count = @statuses.values.sum
        @not_invoiced_values = @total_values.values.sum
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

  def new_purchase_orders_requests
    authorize :sales_order

    service = Services::Overseers::SalesOrders::NewPoRequests.new(@sales_order, current_overseer)
    @po_requests = service.call

  end

  def create_purchase_orders_requests
    authorize :sales_order
    service = Services::Overseers::SalesOrders::UpdatePoRequests.new(@sales_order, current_overseer, new_purchase_orders_requests_params[:po_requests_attributes].to_h)
    service.call

    redirect_to new_purchase_orders_requests_overseers_sales_order_path(@sales_order.to_param)
  end

  private

  def set_sales_order
    @sales_order = SalesOrder.find(params[:id])
  end

  def new_purchase_orders_requests_params
    if params.has_key?(:sales_order)
      params.require(:sales_order).permit(
          :id,
          :po_requests_attributes => [
              :id,
              :supplier_id,
              :inquiry_id,
              :_destroy,
              :logistics_owner_id,
              :address_id,
              :contact_id,
              :status,
              :attachments => [],
              :rows_attributes => [
                  :id,
                  :_destroy,
                  :status,
                  :quantity,
                  :sales_order_row_id
              ]
          ]
      )
    else
      {}
    end
  end
end
