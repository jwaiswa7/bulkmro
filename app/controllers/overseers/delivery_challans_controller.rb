class Overseers::DeliveryChallansController < Overseers::BaseController
  before_action :set_delivery_challan, only: [:show, :edit, :update, :preview]

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
    @stamp = params[:stamp]
    respond_to do |format|
      format.html {render 'show'}
      format.pdf do
        render_pdf_for(@delivery_challan, locals: {delivery_challan: @delivery_challan})
      end
    end
  end

  def new
    @delivery_challan = DeliveryChallan.new(purpose: 20)
  end

  def next_step
    @delivery_challan = Services::Overseers::DeliveryChallans::NewDcFromSo.new(delivery_challan_params, current_overseer).call
    render 'new'
  end

  def create
    @delivery_challan = DeliveryChallan.new(delivery_challan_params)

    if @delivery_challan.save
      redirect_to preview_overseers_delivery_challan_path(@delivery_challan), notice: flash_message(@delivery_challan, action_name)
    else
      render 'new'
    end
  end

  def preview
    
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
        :sales_order_id,
        :customer_po_number,
        :ar_invoice_request_id,
        :supplier_bill_from_id,
        :supplier_ship_from_id,
        :customer_bill_from_id,
        :customer_ship_from_id,
        :goods_type,
        :reason,
        :customer_order_date,
        :sales_order_date,
        :delivery_challan_date,
        :other_reason,
        :customer_request_attachment,
        :purpose,
        rows_attributes: [:id, :product_id, :sr_no, :quantity, :inquiry_product_id, :sales_order_row_id, :_destroy]
      )
    end
end