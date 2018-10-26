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

  def export_all
    authorize :purchase_order
    service = Services::Overseers::Exporters::PurchaseOrdersExporter.new

    respond_to do |format|
      format.html
      format.csv { send_data service.call, filename: service.filename }
    end
  end
end