class Overseers::PurchaseOrders::MaterialReadinessFollowupsController < Overseers::BaseController
  before_action :set_material_readiness_followup, only: [:show, :edit, :update, :confirm_delivery]

  def index
    @material_readiness_followups = ApplyDatatableParams.to(MaterialReadinessFollowup.all, params)
    authorize @material_readiness_followups
  end

  def show
    authorize @mrf
  end

  def new
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    @purchase_order.update_attributes(material_status: :'Material Readiness Follow-Up')
    @mrf = MaterialReadinessFollowup.where(purchase_order_id: @purchase_order.id).first_or_create!

    authorize @mrf

    @po_rows = @purchase_order.rows
    @po_rows.each do |row|
      @mrf.mrf_rows.where(purchase_order_row_id: row.id).first_or_create! do |mrf_row|
        mrf_row.quantity = row.quantity
        mrf_row.pickup_quantity = row.quantity
      end
    end
  end

  def edit
    authorize @mrf
    @purchase_order = @mrf.purchase_order
  end

  def update
    @mrf.assign_attributes(mrf_params)
    @mrf.status = 20
    authorize @mrf

    if @mrf.purchase_order.rows.sum(&:quantity).to_i == @mrf.mrf_rows.sum(&:pickup_quantity).to_i
      @mrf.purchase_order.update_attributes(material_status: :'Material Pickup')
    else
      @mrf.purchase_order.update_attributes(material_status: :'Material Partial Pickup')
    end

    if @mrf.save
      redirect_to overseers_purchase_order_material_readiness_followup_path(@mrf.purchase_order, @mrf), notice: flash_message(@mrf, action_name)
    else
      render 'edit'
    end
  end

  def confirm_delivery
    authorize @mrf
    @purchase_order = @mrf.purchase_order

    @mrf.mrf_rows.each do |row|
      row.update_attributes(delivered_quantity: row.pickup_quantity)
    end

    render 'edit'
  end

  private

  def set_material_readiness_followup
    @mrf = MaterialReadinessFollowup.find(params[:id])
  end

  def mrf_params
    params.require(:material_readiness_followup).permit(
        :status,
        :expected_dispatch_date,
        :expected_delivery_date,
        :actual_delivery_date,
        :type_of_doc,
        :logistics_owner_id,
        :purchase_order,
        :comments_attributes => [:id, :message, :created_by_id, :updated_by_id],
        :mrf_rows_attributes => [:id, :quantity, :pickup_quantity, :delivered_quantity],
        :attachments => []
    )
  end
end