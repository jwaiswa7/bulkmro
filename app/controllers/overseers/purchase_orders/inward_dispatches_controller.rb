class Overseers::PurchaseOrders::InwardDispatchesController < Overseers::BaseController
  before_action :set_inward_dispatch, only: [:show, :edit, :update, :confirm_delivery, :delivered_material]
  before_action :set_purchase_order, only: [:new, :create, :update, :show, :edit]

  def index
    redirect_to material_readiness_queue_overseers_purchase_orders_path()
    authorize_acl :inward_dispatch
  end

  def show
    authorize_acl @inward_dispatch
    @po_request = @purchase_order.po_request
  end

  def new
    @logistics_owner = (@purchase_order.logistics_owner.present?) ? @purchase_order.logistics_owner : @purchase_order.inquiry.company.logistics_owner
    @inward_dispatch = InwardDispatch.new(purchase_order: @purchase_order, logistics_owner: @logistics_owner)
    if @purchase_order.po_request.present?
      @inward_dispatch.sales_order = @purchase_order.po_request.sales_order
    end
    @inward_dispatch.purchase_order.rows.each do |row|
      @inward_dispatch.rows.build(purchase_order_row: row, pickup_quantity: row.get_pickup_quantity, product: row.product)
    end
    authorize_acl @inward_dispatch
  end

  def create
    @inward_dispatch = @purchase_order.inward_dispatches.new()
    @inward_dispatch.assign_attributes(inward_dispatch_params.merge(overseer: current_overseer))
    authorize_acl @inward_dispatch
    if @inward_dispatch.save
      @purchase_order.update_material_status

      redirect_to edit_overseers_purchase_order_inward_dispatch_path(@purchase_order, @inward_dispatch), notice: flash_message(@inward_dispatch, action_name)
    else
      render 'new', notice: @inward_dispatch.errors.full_messages.join(', ')
    end
  end

  def edit
    authorize_acl @inward_dispatch
  end

  def update
    authorize_acl @inward_dispatch
    @inward_dispatch.assign_attributes(inward_dispatch_params.merge(overseer: current_overseer))

    if @inward_dispatch.valid?
      messages = DateModifiedMessage.for(@inward_dispatch, ['expected_dispatch_date', 'expected_delivery_date', 'actual_delivery_date'])
      if messages.present?
        @inward_dispatch.comments.create(message: messages, overseer: current_overseer)
      end
      @inward_dispatch.save
      @purchase_order.update_material_status
      redirect_to overseers_purchase_order_inward_dispatch_path(@inward_dispatch.purchase_order, @inward_dispatch), notice: flash_message(@inward_dispatch, action_name)
    else
      render 'edit', notice: @inward_dispatch.errors.full_messages.join(', ')
    end
  end

  def confirm_delivery
    authorize_acl @inward_dispatch
    @inward_dispatch.status = 'Material Delivered'
    @inward_dispatch.rows.each do |row|
      row.delivered_quantity = row.pickup_quantity
    end
    render 'edit'
  end

  private

    def set_purchase_order
      @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    end

    def set_inward_dispatch
      @inward_dispatch = InwardDispatch.find(params[:id])
    end

    def inward_dispatch_params
      params.require(:inward_dispatch).require(:inward_dispatch).except(:action_name)
        .permit(
          :status,
          :expected_dispatch_date,
          :expected_delivery_date,
          :actual_delivery_date,
          :document_type,
          :logistics_owner_id,
          :dispatched_by,
          :shipped_to,
          :logistics_partner,
          :tracking_number,
          :logistics_aggregator,
          :other_logistics_partner,
          :purchase_order_id,
          :sales_order_id,
          comments_attributes: [:id, :message, :created_by_id, :updated_by_id],
          rows_attributes: [:id, :purchase_order_row_id, :pickup_quantity, :delivered_quantity, :supplier_delivery_date, :_destroy, :product_id],
          attachments: []
        )
    end
end
