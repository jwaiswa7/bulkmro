# frozen_string_literal: true

class Overseers::SalesOrdersController < Overseers::BaseController
  before_action :set_sales_order, only: [:resync]
  def pending
    authorize :sales_order

    respond_to do |format|
      format.html { render 'pending' }
      format.json do
        service = Services::Overseers::Finders::PendingSalesOrders.new(params, current_overseer, paginate: false)
        service.call

        per = (params[:per] || params[:length] || 20).to_i
        page = params[:page] || ((params[:start] || 20).to_i / per + 1)

        @indexed_sales_orders = service.indexed_records.per(per).page(page)
        @sales_orders = service.records.page(page).per(per).try(:reverse)
        puts 'pending'

        if SalesOrder.count != @indexed_sales_orders.total_count
          status_records = service.records.try(:reverse)
          @statuses = status_records.pluck(:status).concat(status_records.pluck(:legacy_request_status))
        else
          @statuses = SalesOrder.all.pluck(:status).concat(SalesOrder.all.pluck(:legacy_request_status))
        end

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
      format.html { }
      format.json do
        service = Services::Overseers::Finders::SalesOrders.new(params, current_overseer, paginate: false)
        service.call

        per = (params[:per] || params[:length] || 20).to_i
        page = params[:page] || ((params[:start] || 20).to_i / per + 1)

        @indexed_sales_orders = service.indexed_records.per(per).page(page)
        @sales_orders = service.records.page(page).per(per).try(:reverse)

        if SalesOrder.count != @indexed_sales_orders.total_count
          status_records = service.records.try(:reverse)
          @statuses = status_records.pluck(:remote_status)
        else
          @statuses = SalesOrder.all.pluck(:remote_status)
        end
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

    sales_orders = SalesOrder.where.not(sent_at: nil).where(draft_uid: nil, status: :'SAP Approval Pending').not_legacy
    respond_to do |format|
      format.html { }
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
