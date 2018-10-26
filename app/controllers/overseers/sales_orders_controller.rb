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

  def export_sheet
    # TODO: Custome Datepicker to generate Sales Orders report
    authorize :sales_order
    start_at = 'Fri, 19 Oct 2018'.to_date
    end_at = Date.today


    respond_to do |format|
      format.html
      format.csv { send_data SalesOrder.to_csv, filename: "sales-orders-#{start_at}-#{end_at}.csv" }
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
