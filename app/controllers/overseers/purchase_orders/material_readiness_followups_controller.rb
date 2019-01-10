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
    @mrf = @purchase_order.material_readiness_followups.build(:overseer => current_overseer)
    authorize @mrf
    @po_rows = @purchase_order.rows
    @po_rows.each do |row|
      @mrf.mrf_rows.where(purchase_order_row_id: row.id).first_or_create! do |mrf_row|
        mrf_row.quantity = row.quantity
        mrf_row.status = 10
      end
    end
  end

  def create
    @mrf = MaterialReadinessFollowup.new(mrf_params.merge(overseer: current_overseer))

    authorize @mrf
    if @mrf.save

      # if @mrf.purchase_order.present?
      #   @po_rows = @mrf.purchase_order.rows
      #   @po_rows.each do |row|
      #     @mrf.mrf_rows.where(purchase_order_row_id: row.id).first_or_create! do |mrf_row|
      #       mrf_row.quantity = row.quantity
      #       mrf_row.status = 10
      #     end
      #   end
      #   @mrf.save
      # end
      redirect_to overseers_purchase_order_material_readiness_followup_path(@mrf.purchase_order, @mrf), notice: flash_message(@mrf, action_name)
    else
      render 'new'
    end
  end

  def edit
    authorize @mrf
  end

  def update
    @kit.assign_attributes(kit_params.merge(overseer: current_overseer))
    authorize @kit
    if @kit.product.approved? ? @kit.save_and_sync : @kit.save
      redirect_to overseers_kit_path(@kit), notice: flash_message(@kit, action_name)
    else
      render 'edit'
    end
  end

  private

  private

  def set_material_readiness_followup
    @mrf = MaterialReadinessFollowup.find(params[:id])
  end

  def mrf_params
    params.require(:set_material_readiness_followup).permit(
        :internal_status,
        :comments_attributes => [:id, :message, :created_by_id],
        :attachments => []
    )
  end
end