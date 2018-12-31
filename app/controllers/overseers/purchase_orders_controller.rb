class Overseers::PurchaseOrdersController < Overseers::BaseController
  before_action :set_purchase_order, only: [:edit_internal_status, :update_internal_status]

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

  def material_readiness_queue
    authorize :purchase_order
    @purchase_orders = ApplyDatatableParams.to(PurchaseOrder.material_readiness_queue, params)
    render 'material_readiness_queue'
  end

  def material_pickup_queue
    authorize :purchase_order
    @purchase_orders = ApplyDatatableParams.to(PurchaseOrder.material_pickup_queue, params)
    render 'material_readiness_queue'
  end

  def edit_internal_status
    authorize @purchase_order
  end

  def update_internal_status
    authorize @purchase_order
    @purchase_order.assign_attributes(purchase_order_params)

    if @purchase_order.save
      redirect_to edit_internal_status_overseers_purchase_order_path, notice: flash_message(@purchase_order, action_name)
    else
      render 'edit_internal_status'
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

  private

  def set_purchase_order
    @purchase_order = PurchaseOrder.find(params[:id])
  end

  def purchase_order_params
    params.require(:purchase_order).permit(
        :internal_status,
    )
  end
end