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
    authorize :purchase_order
    start_at = Date.today - 1.day
    end_at = Date.today

    #service = Services::Shared::Spreadsheets::CsvExporter.new(controller_name.classify.singularize, start_at, end_at, fields, records)
    #service.call

    respond_to do |format|
      format.html
      format.csv { send_data PurchaseOrder.to_csv, filename: "po-#{Date.today}.csv" }
    end
  end
end