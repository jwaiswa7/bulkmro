class Overseers::SalesOrdersController < Overseers::BaseController
  before_action :set_sales_order, only: [:resync, :new_purchase_orders_requests, :preview_purchase_orders_requests, :create_purchase_orders_requests]

  def pending
    authorize_acl :sales_order

    respond_to do |format|
      format.html { render 'pending' }
      format.json do
        service = Services::Overseers::Finders::PendingSalesOrders.new(params, current_overseer)
        service.call

        @indexed_sales_orders = service.indexed_records
        @sales_orders = service.records

        status_service = Services::Overseers::Statuses::GetSummaryStatusBuckets.new(@indexed_sales_orders, SalesOrder)
        status_service.call

        @total_values = status_service.indexed_total_values
        @statuses = status_service.indexed_statuses

        render 'pending'
      end
    end
  end

  def account_approval_pending
    @sales_orders = ApplyDatatableParams.to(SalesOrder.accounts_approval_pending.order(id: :desc), params)
    authorize @sales_orders

    respond_to do |format|
      format.json {render 'account_approval_pending'}
      format.html {render 'account_approval_pending'}
    end
  end

  def cancelled
    authorize_acl :sales_order
    respond_to do |format|
      format.html { render 'pending' }
      format.json do
        service = Services::Overseers::Finders::CancelledSalesOrders.new(params, current_overseer)
        service.call

        @indexed_sales_orders = service.indexed_records
        @sales_orders = service.records

        status_service = Services::Overseers::Statuses::GetSummaryStatusBuckets.new(@indexed_sales_orders, SalesOrder)
        status_service.call

        @total_values = status_service.indexed_total_values
        @statuses = status_service.indexed_statuses
        render 'pending'
      end
    end
  end

  def export_all
    authorize_acl :sales_order
    service = Services::Overseers::Exporters::SalesOrdersExporter.new
    service.call

    redirect_to url_for(Export.sales_orders.not_filtered.last.report)
  end

  def export_rows
    authorize_acl :sales_order
    service = Services::Overseers::Exporters::SalesOrderRowsExporter.new
    service.call

    redirect_to url_for(Export.sales_order_rows.last.report)
  end

  def export_for_logistics
    authorize_acl :sales_order
    service = Services::Overseers::Exporters::SalesOrdersLogisticsExporter.new
    service.call

    redirect_to url_for(Export.sales_order_logistics.last.report)
  end

  def export_for_sap
    authorize_acl :sales_order
    service = Services::Overseers::Exporters::SalesOrdersSapExporter.new
    service.call

    redirect_to url_for(Export.sales_order_sap.last.report)
  end

  def export_for_reco
    authorize_acl :sales_order
    service = Services::Overseers::Exporters::SalesOrdersRecoExporter.new([], current_overseer, [])
    service.call
  end

  def export_filtered_records
    authorize_acl :sales_order
    service = Services::Overseers::Finders::SalesOrders.new(params, current_overseer, paginate: false)
    service.call

    export_service = Services::Overseers::Exporters::SalesOrdersExporter.new([], current_overseer, service.records)
    export_service.call
  end

  def index
    authorize_acl :sales_order
    respond_to do |format|
      format.html { }
      format.json do
        service = Services::Overseers::Finders::SalesOrders.new(params, current_overseer)
        service.call
        @indexed_sales_orders = service.indexed_records
        @sales_orders = service.records

        status_service = Services::Overseers::Statuses::GetSummaryStatusBuckets.new(@indexed_sales_orders, SalesOrder, custom_status: 'remote_status')
        status_service.call

        @total_values = status_service.indexed_total_values
        @statuses = status_service.indexed_statuses
        @statuses_count = @statuses.values.sum
        @sales_order_total = @total_values.values.sum
      end
    end
  end

  def not_invoiced
    authorize_acl :sales_order
    respond_to do |format|
      format.html { render 'not_invoiced' }
      format.json do
        service = Services::Overseers::Finders::NotInvoicedSalesOrders.new(params, current_overseer)
        service.call

        @indexed_sales_orders = service.indexed_records
        @sales_orders = service.records

        status_service = Services::Overseers::Statuses::GetSummaryStatusBuckets.new(@indexed_sales_orders, SalesOrder, custom_status: 'remote_status')
        status_service.call

        @total_values = status_service.indexed_total_values
        @statuses = status_service.indexed_statuses
        @statuses_count = @statuses.values.sum
        @not_invoiced_total = @total_values.values.sum
      end
    end
  end

  def autocomplete
    service = Services::Overseers::Finders::SalesOrders.new(params.merge(page: 1))
    service.call

    @indexed_sales_orders = service.indexed_records
    @sales_orders = service.records.reverse

    authorize_acl :sales_order
  end

  def so_sync_pending
    authorize_acl :sales_order

    #sales_orders = SalesOrder.where.not(sent_at: nil).where(draft_uid: nil, status: :'SAP Approval Pending').not_legacy

    sales_orders = SalesOrder.where.not(sent_at: nil).where(remote_uid: nil, status: :'Approved').where("created_at >= '2019-07-18'")
    respond_to do |format|
      format.html { }
      format.json do
        @drafts_pending_count = sales_orders.count
        @sales_orders = ApplyDatatableParams.to(sales_orders, params)
        render 'so_sync_pending'
      end
    end
  end

  def resync
    authorize_acl :sales_order
    if @sales_order.save_and_sync
      redirect_to so_sync_pending_overseers_sales_orders_path
    end
  end

  def new_purchase_orders_requests
    authorize_acl :sales_order

    if Rails.cache.exist?(:po_requests)
      @po_requests = Rails.cache.read(:po_requests)
      Rails.cache.delete(:po_requests)
    else
      service = Services::Overseers::SalesOrders::NewPoRequests.new(@sales_order, current_overseer)
      @po_requests = service.call
    end
  end

  def preview_purchase_orders_requests
    authorize_acl :sales_order

    service = Services::Overseers::SalesOrders::PreviewPoRequests.new(@sales_order, current_overseer, new_purchase_orders_requests_params[:po_requests_attributes].to_h)
    @po_requests = service.call

    Rails.cache.write(:po_requests, @po_requests, expires_in: 25.minutes)
  end

  def create_purchase_orders_requests
    authorize_acl :sales_order

    service = Services::Overseers::SalesOrders::UpdatePoRequests.new(@sales_order, current_overseer, new_purchase_orders_requests_params[:po_requests_attributes].to_h)
    service.call
    Rails.cache.delete(:po_requests)
    redirect_to pending_and_rejected_overseers_po_requests_path
  end

  def customer_order_status_report
    authorize_acl :sales_order
    @delivery_statuses = ['Delivery Pending', 'All']
    respond_to do |format|
      if params['customer_order_status_report'].present?
        category = params['customer_order_status_report']['category'] if params['customer_order_status_report']['category'].present?
        delivery_status = params['customer_order_status_report']['delivery_status'] if params['customer_order_status_report']['delivery_status'].present?
      else
        category = @categories[0]
        delivery_status = @delivery_statuses[0]
      end
      format.html {}
      format.json do
        service = Services::Overseers::Finders::CustomerOrderStatusReports.new(params, current_overseer, paginate: false)
        service.call
        indexed_sales_orders = service.indexed_records
        sales_orders = Services::Overseers::SalesOrders::FetchCustomerOrderStatusReportData.new(indexed_sales_orders, delivery_status).call
        if delivery_status == @delivery_statuses[0]
          @sales_orders = sales_orders.select { |sales_order| sales_order[:delivery_status] == 'Not Delivered' }
        else
          @sales_orders = sales_orders
        end
        @per = (params['per'] || params['length'] || 20).to_i
        @page = params['page'] || ((params['start'] || 20).to_i / @per + 1)
        @customer_order_status_records = Kaminari.paginate_array(@sales_orders).page(@page).per(@per)
      end
    end
  end

  def export_customer_order_status_report
    authorize_acl :sales_order

    service = Services::Overseers::Finders::CustomerOrderStatusReports.new(params, current_overseer, paginate: false)
    service.call
    indexed_sales_orders = service.indexed_records
    sales_orders = Services::Overseers::SalesOrders::FetchCustomerOrderStatusReportData.new(indexed_sales_orders).call

    export_service = Services::Overseers::Exporters::CustomerOrderStatusReportsExporter.new([], current_overseer, sales_orders, [])
    export_service.call

    redirect_to url_for(Export.customer_order_status_report.not_filtered.last.report)
  end

  def filter_by_status(scope)
    ApplyDatatableParams.to(policy_scope(SalesOrder.all.send(scope).order(id: :desc)), params)
  end

  private

    def set_sales_order
      @sales_order = SalesOrder.find(params[:id])
    end

    def new_purchase_orders_requests_params
      if params.has_key?(:sales_order)
        params.require(:sales_order).permit(
          :id,
            po_requests_attributes: [
                :id,
                :supplier_id,
                :inquiry_id,
                :_destroy,
                :logistics_owner_id,
                :bill_from_id,
                :ship_from_id,
                :bill_to_id,
                :ship_to_id,
                :contact_id,
                :payment_option_id,
                :supplier_po_type,
                :status,
                :supplier_committed_date,
                :contact_email,
                :contact_phone,
                :blobs,
                :transport_mode,
                :delivery_type,
                attachments: [],
                rows_attributes: [
                    :id,
                    :_destroy,
                    :status,
                    :quantity,
                    :sales_order_row_id,
                    :product_id,
                    :brand_id,
                    :tax_code_id,
                    :tax_rate_id,
                    :lead_time,
                    :measurement_unit_id,
                    :discount_percentage,
                    :unit_price
                ]
            ]
        )
      else
        {}
      end
    end
end
