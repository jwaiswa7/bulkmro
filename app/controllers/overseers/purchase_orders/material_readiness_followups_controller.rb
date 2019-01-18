class Overseers::PurchaseOrders::MaterialReadinessFollowupsController < Overseers::BaseController
  before_action :set_material_readiness_followup, only: [:show, :edit, :update, :confirm_delivery, :delivered_material]

  def index

    redirect_to material_readiness_queue_overseers_purchase_orders_path()
    authorize :material_readiness_followup
  end

  def show
    authorize @mrf
  end

  def new
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    @logistics_owner = Services::Overseers::MaterialReadinessFollowups::SelectLogisticsOwner.new(@purchase_order).call
    @mrf = MaterialReadinessFollowup.new(purchase_order: @purchase_order,
                                         logistics_owner: @logistics_owner)

    authorize @mrf
  end

  def create
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    @mrf = @purchase_order.material_readiness_followups.new(mrf_params.merge(overseer: current_overseer))

    authorize @mrf
    if @mrf.save!
      redirect_to edit_overseers_purchase_order_material_readiness_followup_path(@purchase_order, @mrf), notice: flash_message(@mrf, action_name)
    else
      'new'
    end
  end

  def edit
    authorize @mrf
    if @mrf.purchase_order.present? && @mrf.rows.blank?
      @mrf.purchase_order.rows.each do |row|
        row = @mrf.rows.build(purchase_order_row: row, pickup_quantity: row.get_pickup_quantity)
        row.save
      end
    end
  end

  def update
    authorize @mrf
    @mrf.assign_attributes(mrf_params.merge(:overseer => current_overseer))
    if @mrf.save
      redirect_to overseers_purchase_order_material_readiness_followup_path(@mrf.purchase_order, @mrf), notice: flash_message(@mrf, action_name)
    else
      render 'edit'
    end
  end

  def delivered_material
    authorize @mrf
  end

  def confirm_delivery
    authorize @mrf
    @mrf.status = 'Material Delivered'
    @mrf.rows.each do |row|
      row.delivered_quantity = row.pickup_quantity
    end
    render 'edit'
  end

  private

  def set_material_readiness_followup
    @mrf = MaterialReadinessFollowup.find(params[:id])
  end

  def mrf_params
    params.require(:material_readiness_followup).require(:material_readiness_followup).except(:action_name)
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