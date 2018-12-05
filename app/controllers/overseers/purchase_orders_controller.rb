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

  def autocomplete
    if params[:inquiry_number].present?
      @purchase_orders = ApplyParams.to(PurchaseOrder.joins(:inquiry).where(inquiries: {inquiry_number: params[:inquiry_number]}), params)
    else
      @purchase_orders = ApplyParams.to(PurchaseOrder.all, params)
    end

    authorize :purchase_order
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