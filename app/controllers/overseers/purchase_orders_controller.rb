class Overseers::PurchaseOrdersController < Overseers::BaseController

  def index
    authorize :purchase_order

    respond_to do |format|
      format.html {}
      format.json do
        service = Services::Overseers::Finders::PurchaseOrders.new(params, current_overseer, paginate: false)
        service.call

        per = (params[:per] || params[:length] || 20).to_i
        page = params[:page] || ((params[:start] || 20).to_i / per + 1)

        @indexed_purchase_orders = service.indexed_records.per(per).page(page)
        @purchase_orders = service.records.page(page).per(per).try(:reverse)

        if (PurchaseOrder.count != @indexed_purchase_orders.total_count)
          status_records = service.records.try(:reverse)
          @statuses = status_records.map(&:metadata_status)
        else
          @statuses = PurchaseOrder.all.map(&:metadata_status)
        end
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