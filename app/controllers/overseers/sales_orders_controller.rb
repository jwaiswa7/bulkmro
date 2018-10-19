class Overseers::SalesOrdersController < Overseers::BaseController

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
end
