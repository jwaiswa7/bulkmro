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

        status_service = Services::Overseers::Statuses::GetSummaryStatusBuckets.new(@indexed_purchase_orders, PurchaseOrder)
        status_service.call

        @statuses = status_service.indexed_statuses
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
    service.call

    redirect_to url_for(Export.purchase_orders.last.report)
  end
end