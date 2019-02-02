class Overseers::SalesOrdersController < Overseers::BaseController
  before_action :set_sales_order, only: [ :resync, :new_purchase_orders_requests,  :preview_purchase_orders_requests,:create_purchase_orders_requests]
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
    service = Services::Overseers::Exporters::SalesOrdersExporter.new(headers)
    self.response_body = service.call
    # Set the status to success
    response.status = 200
  end

  def export_rows
    authorize :sales_order
    service = Services::Overseers::Exporters::SalesOrderRowsExporter.new(headers)
    self.response_body = service.call
    # Set the status to success
    response.status = 200
  end

  def export_for_logistics
    authorize :sales_order
    service = Services::Overseers::Exporters::SalesOrdersLogisticsExporter.new(headers)
    self.response_body = service.call
    # Set the status to success
    response.status = 200
  end

  def export_for_sap
    authorize :sales_order
    service = Services::Overseers::Exporters::SalesOrdersSapExporter.new(headers)
    self.response_body = service.call
    # Set the status to success
    response.status = 200
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
        @statuses_count = @statuses.values.sum
        @sales_order_total = @total_values.values.sum
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
        @not_invoiced_total = @total_values.values.sum
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
    service = Services::Overseers::CompanyReviews::CreateCompanyReview .new(@sales_order,current_overseer)
    @company_reviews = service.call

    if Rails.cache.exist?(:po_requests)
      @po_requests =  Rails.cache.read(:po_requests)
      Rails.cache.delete(:po_requests)
    else
      service = Services::Overseers::SalesOrders::NewPoRequests.new(@sales_order, current_overseer)
      @po_requests = service.call
    end
  end

  def preview_purchase_orders_requests
    authorize :sales_order

    service = Services::Overseers::SalesOrders::PreviewPoRequests.new(@sales_order, current_overseer, new_purchase_orders_requests_params[:po_requests_attributes].to_h)
    @po_requests = service.call

    Rails.cache.write(:po_requests, @po_requests, expires_in: 25.minutes)
  end

  def create_purchase_orders_requests
    authorize :sales_order

    service = Services::Overseers::SalesOrders::UpdatePoRequests.new(@sales_order, current_overseer, new_purchase_orders_requests_params[:po_requests_attributes].to_h)
    service.call
    Rails.cache.delete(:po_requests)
    redirect_to pending_and_rejected_overseers_po_requests_path
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
              :bill_from_id,
              :ship_from_id,
              :bill_to_id,
              :ship_to_id,
              :contact_id,
              :payment_option_id,
              :supplier_po_type,
              :status,
              :supplier_committed_date,
              :blobs,
              :attachments => [],
              :rows_attributes => [
                  :id,
                  :_destroy,
                  :status,
                  :quantity,
                  :sales_order_row_id,
                  :product_id,
                  :brand_id,
                  :tax_code_id,
                  :tax_rate_id,
                  :measurement_unit_id,
                  :unit_price
              ]
          ]
      )
    else
      {}
    end
  end
end
