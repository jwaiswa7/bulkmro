class Overseers::PurchaseOrders::MaterialReadinessFollowupsController < Overseers::BaseController
  before_action :set_material_readiness_followup, only: [:show, :edit, :update]

  def index
    @material_readiness_followups = ApplyDatatableParams.to(MaterialReadinessFollowup.all, params)
    authorize @material_readiness_followups
  end

  def show
    authorize @mrf
  end

  def new
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    @mrf = MaterialReadinessFollowup.where(purchase_order_id: @purchase_order.id).first_or_create! do
      @mrf.status = 20
    end

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
  end

  def update
    @mrf.assign_attributes(mrf_params)
    authorize @mrf
    if @mrf.save
      redirect_to overseers_kit_path(@kit), notice: flash_message(@kit, action_name)
    else
      render 'edit'
    end
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