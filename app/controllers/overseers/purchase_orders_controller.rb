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
    @purchase_orders = ApplyDatatableParams.to(PurchaseOrder.material_readiness_queue, params)
    render 'material_readiness_queue'
  end

  def material_pickup_queue
    @status = 'Material Pickup Queue'
    @material_readiness_followups = ApplyDatatableParams.to(MaterialReadinessFollowup.where(status: :'Material Pickup').order("created_at DESC"), params)
    authorize @material_readiness_followups
    render 'material_pickup_queue'
  end

  def material_delivered_queue
    @status = 'Material Delivered Queue'
    @material_readiness_followups = ApplyDatatableParams.to(MaterialReadinessFollowup.where(status: :'Material Delivered').order("created_at DESC"), params)
    authorize @material_readiness_followups
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
      ActiveRecord::Base.transaction do
        if @purchase_order.supplier_dispatch_date_changed?
          @po_comment = PoComment.new(:message => "Supplier Dispatch Date Changed: #{@purchase_order.supplier_dispatch_date.try(:strftime, "%d-%b-%Y")}", :purchase_order => @purchase_order, :overseer => current_overseer)
          @po_comment.save!
        end

        if @purchase_order.revised_supplier_delivery_date_changed?
          @po_comment = PoComment.new(:message => "Revised Supplier Delivery Date To: #{@purchase_order.revised_supplier_delivery_date.try(:strftime, "%d-%b-%Y")}", :purchase_order => @purchase_order, :overseer => current_overseer)
          @po_comment.save!
        end
        @purchase_order.save!
      end
      redirect_to edit_material_followup_overseers_purchase_order_path, notice: flash_message(@purchase_order, action_name)
    else
      render 'edit_material_followup'
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
        :material_status,
        :supplier_dispatch_date,
        :revised_supplier_delivery_date,
        :comments_attributes => [:id, :message, :created_by_id],
        :attachments => []
    )
  end
end