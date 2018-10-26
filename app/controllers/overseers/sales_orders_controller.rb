class Overseers::SalesOrdersController < Overseers::BaseController
  before_action :set_sales_order, only: [ :resync]
  def pending
    authorize :sales_order

    respond_to do |format|
      format.html { render 'index' }
      format.json do
        service = Services::Overseers::Finders::PendingSalesOrders.new(params, current_overseer)
        service.call

        @indexed_sales_orders = service.indexed_records
        @sales_orders = service.records.try(:reverse)

        render 'index'
      end
    end
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
      end
    end
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
