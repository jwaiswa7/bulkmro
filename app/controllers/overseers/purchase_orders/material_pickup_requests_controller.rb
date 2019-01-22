class Overseers::PurchaseOrders::MaterialPickupRequestsController < Overseers::BaseController
  before_action :set_material_pickup_request, only: [:show, :edit, :update, :confirm_delivery, :delivered_material]
  before_action :set_purchase_order, only: [:new, :create, :update]

  def index

    redirect_to material_readiness_queue_overseers_purchase_orders_path()
    authorize :material_pickup_request
  end

  def show
    authorize @mpr
  end

  def new
    @logistics_owner = Services::Overseers::MaterialPickupRequests::SelectLogisticsOwner.new(@purchase_order).call
    @mpr = MaterialPickupRequest.new(purchase_order: @purchase_order, logistics_owner: @logistics_owner)

    @mpr.purchase_order.rows.each do |row|
      @mpr.rows.build(purchase_order_row: row, pickup_quantity: row.get_pickup_quantity)
    end
    authorize @mpr
  end

  def create
    @mpr = @purchase_order.material_pickup_requests.new()
    @mpr.assign_attributes(mpr_params.merge(:overseer => current_overseer))
    authorize @mpr
    if @mpr.save
      @purchase_order.update_material_status

      redirect_to edit_overseers_purchase_order_material_pickup_request_path(@purchase_order, @mpr), notice: flash_message(@mpr, action_name)
    else
      'new'
    end
  end

  def edit
    authorize @mpr
  end

  def update
    authorize @mpr

    @mpr.assign_attributes(mpr_params.merge(:overseer => current_overseer))

    if @mpr.valid?
      messages = DateModifiedMessage.for(@mpr, ['expected_dispatch_date', 'expected_delivery_date', 'actual_delivery_date'])
      if messages.present?
        @mpr.comments.create(:message => messages, :overseer => current_overseer)
      end
      @mpr.save
      @purchase_order.update_material_status
      redirect_to overseers_purchase_order_material_pickup_request_path(@mpr.purchase_order, @mpr), notice: flash_message(@mpr, action_name)
    else
      render 'edit'
    end
  end

  def confirm_delivery
    authorize @mpr
    @mpr.status = 'Material Delivered'
    @mpr.rows.each do |row|
      row.delivered_quantity = row.pickup_quantity
    end
    render 'edit'
  end

  private

  def set_purchase_order
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
  end

  def set_material_pickup_request
    @mpr = MaterialPickupRequest.find(params[:id])
  end

  def mpr_params
    params.require(:material_pickup_request).require(:material_pickup_request).except(:action_name)
        .permit(
            :status,
            :expected_dispatch_date,
            :expected_delivery_date,
            :actual_delivery_date,
            :document_type,
            :logistics_owner_id,
            :purchase_order_id,
            :comments_attributes => [:id, :message, :created_by_id, :updated_by_id],
            :rows_attributes => [:id, :purchase_order_row_id, :pickup_quantity, :delivered_quantity, :_destroy],
            :attachments => []
        )
  end
end