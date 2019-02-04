class Overseers::PurchaseOrdersController < Overseers::BaseController
  before_action :set_purchase_order, only: [:edit_material_followup, :update_material_followup]

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

        @total_values = status_service.indexed_total_values
        @statuses = status_service.indexed_statuses
      end
    end
  end

  def material_readiness_queue
    authorize :purchase_order

    respond_to do |format|
      format.html {}
      format.json do
        service = Services::Overseers::Finders::MaterialReadinessQueues.new(params, current_overseer)
        service.call

        @indexed_purchase_orders = service.indexed_records
        @purchase_orders = service.records.try(:reverse)
      end
    end

=begin
    @purchase_orders = ApplyDatatableParams.to(PurchaseOrder.material_readiness_queue, params).joins(:po_request).where("po_requests.status = ?", 20).order("purchase_orders.created_at DESC")
=end
    render 'material_readiness_queue'
  end

  def material_pickup_queue
    @status = 'Material Pickup Queue'


    base_filter = {
        :base_filter_key => "status",

        :base_filter_value => MaterialPickupRequest.statuses['Material Pickup']
    }


    respond_to do |format|
      format.html {}
      format.json do

        service = Services::Overseers::Finders::MaterialPickupRequests.new(params.merge(base_filter), current_overseer)

        service.call

        @indexed_material_pickup_requests = service.indexed_records
        @material_pickup_requests = service.records.try(:reverse)
      end
    end

    authorize :material_pickup_request
    render 'material_pickup_queue'
  end

  def material_delivered_queue
    @status = 'Material Delivered Queue'

    base_filter = {
        :base_filter_key => "status",

        :base_filter_value => MaterialPickupRequest.statuses['Material Delivered']
    }


    respond_to do |format|
      format.html {}
      format.json do

        service = Services::Overseers::Finders::MaterialPickupRequests.new(params.merge(base_filter), current_overseer)

        service.call

        @indexed_material_pickup_requests = service.indexed_records
        @material_pickup_requests = service.records.try(:reverse)
      end
    end

    authorize :material_pickup_request
    render 'material_pickup_queue'
  end

  def edit_material_followup
    authorize @purchase_order
    @po_request = @purchase_order.po_request
  end

  def update_material_followup
    authorize @purchase_order
    @purchase_order.assign_attributes(purchase_order_params)

    if @purchase_order.valid?

      messages = DateModifiedMessage.for(@purchase_order, ['supplier_dispatch_date', 'revised_supplier_delivery_date', 'followup_date'])
      if messages.present?
        @purchase_order.comments.create(:message => messages, :overseer => current_overseer)
      end

      @purchase_order.save
      redirect_to edit_material_followup_overseers_purchase_order_path, notice: flash_message(@purchase_order, action_name)
    else
      render 'edit_material_followup'
    end
  end

  def autocomplete
    purchase_orders = PurchaseOrder.all
    if params[:inquiry_number].present?
      purchase_orders = PurchaseOrder.joins(:inquiry).where(inquiries: {inquiry_number: params[:inquiry_number]})
      #purchase_orders = purchase_orders.where.not(:id => PoRequest.not_cancelled.pluck(:purchase_order_id)) if params[:has_po_request]

    end
    @purchase_orders = ApplyParams.to(purchase_orders, params)

    authorize :purchase_order
  end

  def export_all
    authorize :purchase_order
    service = Services::Overseers::Exporters::PurchaseOrdersExporter.new(headers)
    self.response_body = service.call
    # Set the status to success
    response.status = 200
  end

  private

  def set_purchase_order
    @purchase_order = PurchaseOrder.find(params[:id])
  end

  def purchase_order_params
    params.require(:purchase_order).permit(
        :material_status,
        :supplier_dispatch_date,
        :followup_date,
        :revised_supplier_delivery_date,
        :comments_attributes => [:id, :message, :created_by_id],
        :attachments => []
    )
  end
end