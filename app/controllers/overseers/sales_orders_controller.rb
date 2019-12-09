class Overseers::SalesOrdersController < Overseers::BaseController
  before_action :set_sales_order, only: [:resync, :new_purchase_orders_requests, :preview_purchase_orders_requests, :create_purchase_orders_requests, :render_modal_form, :add_comment]

  def pending
    authorize_acl :sales_order

    respond_to do |format|
      format.html {
        @statuses = SalesOrder.statuses.except("Approved", "Order Deleted", "Hold by Finance", "Cancelled")
        @main_summary_statuses = SalesOrder.main_summary_statuses
        render 'pending'
      }
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
        @main_summary_statuses = SalesOrder.main_summary_statuses
        render 'pending'
      end
    end
  end

  def export_all
    authorize_acl :sales_order
    service = Services::Overseers::Exporters::SalesOrdersExporter.new
    service.call

    redirect_to url_for(Export.sales_orders.not_filtered.completed.last.report)
  end

  def export_rows
    authorize_acl :sales_order
    service = Services::Overseers::Exporters::SalesOrderRowsExporter.new
    service.call

    redirect_to url_for(Export.sales_order_rows.last.report)
  end

  def export_rows_in_bible_format
    authorize_acl :sales_order

    service = Services::Overseers::Exporters::SalesOrdersBibleFormatExporter.new
    service.call

    if Export.sales_orders_bible_format.last.present?
      redirect_to url_for(Export.sales_orders_bible_format.last.report)
    else
      redirect_to overseers_sales_orders_path
    end
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
    service = Services::Overseers::Finders::SalesOrders.new(params, current_overseer)
    service.call
    @indexed_sales_orders = service.indexed_records
    @sales_orders = service.records

    status_service = Services::Overseers::Statuses::GetSummaryStatusBuckets.new(@indexed_sales_orders, SalesOrder, custom_status: 'remote_status', main_summary_status: SalesOrder.main_summary_statuses)
    status_service.call

    respond_to do |format|
      format.html {
        @statuses = SalesOrder.remote_statuses
        @alias_name = 'Total Sales Order'
        @main_summary_statuses = SalesOrder.main_summary_statuses
      }
      format.json do
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
        @main_summary_statuses = SalesOrder.main_summary_statuses
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

    # sales_orders = SalesOrder.where.not(sent_at: nil).where(draft_uid: nil, status: :'SAP Approval Pending').not_legacy

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

  def resync_all_sales_orders
    authorize_acl :sales_order
    service = Services::Overseers::SalesOrders::ResyncAllSalesOrders.new
    service.call
    redirect_to so_sync_pending_overseers_sales_orders_path
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
    @categories = ['By BM', 'By Sales Order']
    @delivery_statuses = ['Delivery Pending', 'All']
    respond_to do |format|
      if params['customer_order_status_report'].present?
        delivery_status = params['customer_order_status_report']['delivery_status'] if params['customer_order_status_report']['delivery_status'].present?
      else
        params['customer_order_status_report'] = { 'category': @categories[0] }
        delivery_status = @delivery_statuses[0]
      end
      format.html {}
      format.json do
        service = Services::Overseers::Finders::CustomerOrderStatusReports.new(params, current_overseer, paginate: false)
        service.call
        indexed_sales_orders = service.indexed_records
        if params['customer_order_status_report']['category'] == 'By Sales Order'
          sales_orders = Services::Overseers::SalesOrders::FetchCustomerOrderStatusReportData.new(indexed_sales_orders, delivery_status).fetch_data_sales_order_wise
        else
          sales_orders = Services::Overseers::SalesOrders::FetchCustomerOrderStatusReportData.new(indexed_sales_orders, delivery_status).fetch_data_bm_wise
        end
        if delivery_status == @delivery_statuses[0] && params['customer_order_status_report']['category'] == 'By Sales Order'
          @sales_orders = sales_orders.select { |sales_order| sales_order[:delivery_status] == 'Not Delivered' }
        elsif delivery_status == @delivery_statuses[0] && params['customer_order_status_report']['category'] == 'By BM'
          @sales_orders = sales_orders.select { |sales_order| sales_order[:delivery_status] == 'Not Delivered' }
        else
          @sales_orders = sales_orders
        end
        @per = (params['per'] || params['length'] || 20).to_i
        @page = params['page'] || ((params['start'] || 20).to_i / @per + 1)
        if params[:order].present? && params[:order].values.first['column'].present? && params[:columns][params[:order].values.first['column']][:name].present? && params[:order].values.first['dir'].present?
          sort_by = params[:columns][params[:order].values.first['column']][:name]
          sort_order = params[:order].values.first['dir']
          sorted_indexed_sales_orders = @sales_orders.present? ? sort_buckets(sort_by, sort_order, @sales_orders) : @sales_orders
        end
        if sorted_indexed_sales_orders.present?
          @customer_order_status_records = Kaminari.paginate_array(sorted_indexed_sales_orders).page(@page).per(@per)
        else
          @customer_order_status_records = Kaminari.paginate_array(@sales_orders).page(@page).per(@per)
        end
      end
    end
  end

  def export_customer_order_status_report
    authorize_acl :sales_order
    @categories = ['By BM', 'By Sales Order']
    @delivery_statuses = ['Delivery Pending', 'All']
    if params['customer_order_status_report'].present?
      delivery_status = params['customer_order_status_report']['delivery_status'] if params['customer_order_status_report']['delivery_status'].present?
      params['customer_order_status_report']['procurement_specialist'] = params['customer_order_status_report']['procurement_specialist'].split('.')[0] if params['customer_order_status_report']['procurement_specialist'].present?
    else
      params['customer_order_status_report'] = { 'category': @categories[0] }
      delivery_status = @delivery_statuses[0]
    end

    service = Services::Overseers::Finders::CustomerOrderStatusReports.new(params, current_overseer, paginate: false)
    service.call

    indexed_sales_orders = service.indexed_records
    if params['customer_order_status_report']['category'] == 'By Sales Order'
      sales_orders = Services::Overseers::SalesOrders::FetchCustomerOrderStatusReportData.new(indexed_sales_orders, delivery_status).fetch_data_sales_order_wise
    else
      sales_orders = Services::Overseers::SalesOrders::FetchCustomerOrderStatusReportData.new(indexed_sales_orders, delivery_status).fetch_data_bm_wise
    end
    if delivery_status == @delivery_statuses[0]
      @sales_orders = sales_orders.select { |sales_order| sales_order[:delivery_status] == 'Not Delivered' }
    else
      @sales_orders = sales_orders
    end

    export_service = Services::Overseers::Exporters::CustomerOrderStatusReportsExporter.new([], current_overseer, @sales_orders, [])
    export_service.call

    redirect_to url_for(Export.customer_order_status_report.not_filtered.last.report)
  end

  def filter_by_status(scope)
    ApplyDatatableParams.to(policy_scope(SalesOrder.all.send(scope).order(id: :desc)), params)
  end

  def render_modal_form
    authorize_acl @sales_order
    respond_to do |format|
      if params[:title] == 'Comment'
        format.html {render partial: 'shared/layouts/add_comment', locals: {obj: @sales_order, url: add_comment_overseers_sales_order_path(@sales_order), view_more: overseers_inquiry_comments_path(@sales_order.inquiry.id)}}
      end
    end
  end

  def add_comment
    @sales_order.assign_attributes(new_purchase_orders_requests_params.merge(overseer: current_overseer))
    authorize_acl @sales_order
    if @sales_order.valid?
      message = params['sales_order']['comments_attributes']['0']['message']
      if message.present?
        ActiveRecord::Base.transaction do
          @sales_order.save!
          @sales_order_comment = @sales_order.comments.create(message: message, inquiry: @sales_order.inquiry, overseer: current_overseer)
        end
        render json: {success: 1, message: 'Successfully updated '}, status: 200
      else
        render json: {error: {base: 'Field cannot be blank!'}}, status: 500
      end
    else
      render json: {error: @sales_order.errors}, status: 500
    end
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
                ],
            comments_attributes: [
            :created_by_id,
            :updated_by_id,
            :message,
            :inquiry_id,
        ]
            ],
        )
      else
        {}
      end
    end

    def sort_buckets(sort_by, sort_order, indexed_sales_reports)
      value_present = indexed_sales_reports[0][sort_by].present? && indexed_sales_reports[0][sort_by]['value'].present?
      case
      when !value_present && sort_order == 'asc'
        indexed_sales_reports.sort! { |a, b| a['doc_count'] <=> b['doc_count'] }
      when !value_present && sort_order == 'desc'
        indexed_sales_reports.sort! { |a, b| a['doc_count'] <=> b['doc_count'] }.reverse!
      when value_present && sort_order == 'asc'
        indexed_sales_reports.sort! { |a, b| a[sort_by]['value'] <=> b[sort_by]['value'] }
      when value_present && sort_order == 'desc'
        indexed_sales_reports.sort! { |a, b| a[sort_by]['value'] <=> b[sort_by]['value'] }.reverse!
      end
    end
end
