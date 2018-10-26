class Overseers::PurchaseOrdersController < Overseers::BaseController

  def index
    authorize :purchase_order

    respond_to do |format|
      format.html {}
      format.json do
        service = Services::Overseers::Finders::PurchaseOrders.new(params, current_overseer)
        service.call
        @indexed_purchase_orders = service.indexed_records
        @purchase_orders = service.records.try(:reverse)
      end
    end
  end

  def export_sheet
    # TODO: Custome Datepicker to generate Purchase Order report
    authorize :purchase_order
    start_at = Date.today - 2.day
    end_at = Date.today

    respond_to do |format|
      format.html
      format.csv { send_data PurchaseOrder.to_csv, filename: "purchase-orders-#{start_at}-#{end_at}.csv" }
    end
  end
end