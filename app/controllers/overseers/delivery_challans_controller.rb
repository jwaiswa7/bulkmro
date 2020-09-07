class Overseers::DeliveryChallansController < Overseers::BaseController
  before_action :set_delivery_challan, only: [:show, :edit, :update]

  def index
    service = Services::Overseers::Finders::DeliveryChallans.new(params)
    service.call
    @indexed_delivery_challans = service.indexed_records
    @delivery_challans = service.records
    authorize_acl @delivery_challans
  end

  def autocomplete
    @delivery_challans = ApplyParams.to(DeliveryChallan.all, params)
    authorize_acl @delivery_challans
  end

  def show
    authorize_acl @delivery_challan
  end

  def new
    @delivery_challan = DeliveryChallan.new
    authorize_acl @delivery_challan
  end

  def create
    @delivery_challan = DeliveryChallan.new(delivery_challan_params)
    authorize_acl @delivery_challan

    if @delivery_challan.save
      redirect_to overseers_delivery_challans_path, notice: flash_message(@delivery_challan, action_name)
    else
      render 'new'
    end
  end

  def edit
    authorize_acl @delivery_challan
  end

  def update
    @delivery_challan.assign_attributes(delivery_challan_params)
    authorize_acl @delivery_challan

    if @delivery_challan.save
      redirect_to overseers_delivery_challan_path(@delivery_challan), notice: flash_message(@delivery_challan, action_name)
    else
      render 'edit'
    end
  end

  private

    def set_delivery_challan
      @delivery_challan ||= DeliveryChallan.find(params[:id])
    end

    def delivery_challan_params
      params.require(:delivery_challan).permit(
        :id,
        :inquiry_id,
        :goods_type,
        :quantity,
        :reason
      )
    end
end