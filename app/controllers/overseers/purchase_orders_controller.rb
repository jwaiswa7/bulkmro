class Overseers::PurchaseOrdersController < Overseers::BaseController
  before_action :set_purchase_order, only: [:show, :edit_material_followup, :update_material_followup]

  def index
    authorize :purchase_order
    respond_to do |format|
      format.html { }
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

  def show
    authorize @purchase_order
    @inquiry = @purchase_order.inquiry
    @metadata = @purchase_order.metadata.deep_symbolize_keys
    @supplier = get_supplier(@purchase_order, @purchase_order.rows.first.metadata['PopProductId'].to_i)
    @metadata[:packing] = @purchase_order.get_packing(@metadata)

    respond_to do |format|
      format.html { }
      format.pdf do
        render_pdf_for(@purchase_order, locals: { inquiry: @inquiry, purchase_order: @purchase_order, metadata: @metadata, supplier: @supplier })
      end
    end
  end

  def material_readiness_queue
    authorize :purchase_order

    respond_to do |format|
      format.html { }
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
        base_filter_key: 'status',

        base_filter_value: MaterialPickupRequest.statuses['Material Pickup']
    }


    respond_to do |format|
      format.html { }
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
        base_filter_key: 'status',

        base_filter_value: MaterialPickupRequest.statuses['Material Delivered']
    }


    respond_to do |format|
      format.html { }
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
        @purchase_order.comments.create(message: messages, overseer: current_overseer)
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
      purchase_orders = PurchaseOrder.joins(:inquiry).where(inquiries: { inquiry_number: params[:inquiry_number] })
      purchase_orders = purchase_orders.where(id: purchase_orders.pluck(:id))
    end
    @purchase_orders = ApplyParams.to(purchase_orders, params)

    authorize :purchase_order
  end

  def autocomplete_without_po_requests
    purchase_orders = PurchaseOrder.all
    if params[:inquiry_number].present?
      purchase_orders = PurchaseOrder.joins(:inquiry).where(inquiries: { inquiry_number: params[:inquiry_number] })
      purchase_orders = purchase_orders.where(id: purchase_orders.reject { |r| r.po_request.present? }.pluck(:id))
    end
    @purchase_orders = ApplyParams.to(purchase_orders, params)

    authorize :purchase_order
  end

  def export_all
    authorize :purchase_order
    service = Services::Overseers::Exporters::PurchaseOrdersExporter.new([], current_overseer, [])
    service.call

    redirect_to url_for(Export.purchase_orders.not_filtered.last.report)
  end

  def export_filtered_records
    authorize :purchase_order
    service = Services::Overseers::Finders::PurchaseOrders.new(params, current_overseer, paginate: false)
    service.call

    export_service = Services::Overseers::Exporters::PurchaseOrdersExporter.new([], current_overseer, service.records.pluck(:id))
    export_service.call
  end

  def update_logistics_owner
    @purchase_orders = PurchaseOrder.where(id: params[:purchase_orders])
    authorize @purchase_orders
    @purchase_orders.each do |purchase_order|
      purchase_order.update_attributes(logistics_owner_id: params[:logistics_owner_id])
    end
  end

  def update_logistics_owner_for_pickup_requests
    @pickup_requests = MaterialPickupRequest.where(id: params[:pickup_requests])
    authorize @pickup_requests
    @pickup_requests.each do |pickup_request|
      pickup_request.update_attributes(logistics_owner_id: params[:logistics_owner_id])
    end
  end

  private

    def get_supplier(purchase_order, product_id)
      if purchase_order.metadata['PoSupNum'].present?
        product_supplier = (Company.find_by_legacy_id(purchase_order.metadata['PoSupNum']) || Company.find_by_remote_uid(purchase_order.metadata['PoSupNum']))
        return product_supplier if purchase_order.inquiry.suppliers.include?(product_supplier) || purchase_order.is_legacy?
      end
      if purchase_order.inquiry.final_sales_quote.present?
        product_supplier = purchase_order.inquiry.final_sales_quote.rows.select { |sales_quote_row| sales_quote_row.product.id == product_id || sales_quote_row.product.legacy_id == product_id }.first
        product_supplier.supplier if product_supplier.present?
      end
    end

    def set_purchase_order
      @purchase_order = PurchaseOrder.find(params[:id])
    end

    def purchase_order_params
      params.require(:purchase_order).permit(
        :material_status,
          :supplier_dispatch_date,
          :followup_date,
          :logistics_owner_id,
          :revised_supplier_delivery_date,
          comments_attributes: [:id, :message, :created_by_id],
          attachments: []
      )
    end
end
