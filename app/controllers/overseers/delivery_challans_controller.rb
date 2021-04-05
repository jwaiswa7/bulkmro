class Overseers::DeliveryChallansController < Overseers::BaseController
  before_action :set_delivery_challan, only: [:show, :edit, :update, :preview, :relationship_map, :get_relationship_map_json]
  before_action :set_inquiry_so_and_inward, only: :new

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
    @inquiry = @delivery_challan.inquiry
    respond_to do |format|
      format.html {render 'show'}
      format.pdf do
        render_pdf_for(@delivery_challan, locals: {delivery_challan: @delivery_challan})
      end
    end
  end

  def new
    created_from = params[:created_from].present? ? params[:created_from] : 'DeliveryChallan'
    @delivery_challan = DeliveryChallan.new(purpose: 20, inquiry: @inquiry, sales_order: @sales_order, 
      inward_dispatch: @inward_dispatch, created_from: created_from)
    authorize_acl @delivery_challan
  end

  def next_step
    @delivery_challan = Services::Overseers::DeliveryChallans::NewDcFromSo.new(delivery_challan_params, current_overseer).call
    authorize_acl @delivery_challan
    render 'new'
  end

  def create
    @delivery_challan = DeliveryChallan.new(delivery_challan_params.merge(overseer: current_overseer))
    authorize_acl @delivery_challan

    if @delivery_challan.save
      dc_number = Services::Resources::Shared::UidGenerator.generate_dc_number(@delivery_challan)
      @delivery_challan.update_attributes(delivery_challan_number: dc_number)
      redirect_to preview_overseers_delivery_challan_path(@delivery_challan)
    else
      render 'new'
    end
  end

  def preview
    authorize_acl @delivery_challan
  end

  def edit
    authorize_acl @delivery_challan
  end

  def update
    authorize_acl @delivery_challan

    if params[:preview].present?
      redirect_to overseers_delivery_challans_path, notice: flash_message(@delivery_challan, 'create')
    else
      @delivery_challan.assign_attributes(delivery_challan_params.merge(overseer: current_overseer))

      if @delivery_challan.valid?
        messages = FieldModifiedMessage.for(@delivery_challan, message_fields(@delivery_challan))

        @delivery_challan.rows.each do |row|
          messages << FieldModifiedMessage.for(row, ['quantity'])
        end
        if messages.present?
          @delivery_challan.comments.create(message: messages, overseer: current_overseer)
        end
        @delivery_challan.save
        redirect_to preview_overseers_delivery_challan_path(@delivery_challan), notice: flash_message(@delivery_challan, action_name)
      else
        render 'edit'
      end
    end
  end

  def relationship_map
    authorize_acl @delivery_challan
  end

  def get_relationship_map_json
    authorize_acl @delivery_challan
    # purchase_order = PurchaseOrder.includes(po_request: :sales_order).where(inquiry_id: @inquiry).where(po_requests: {id: nil}, sales_orders: {id: nil})
    # inquiry_json = Services::Overseers::Inquiries::RelationshipMap.new(@inquiry, @inquiry.sales_quotes, purchase_order).call
    # render json: {data: inquiry_json}
    #
    inquiry_json = Services::Overseers::DeliveryChallans::RelationshipMap.new(@delivery_challan).call
    render json: {data: inquiry_json}
  end

  private

    def set_delivery_challan
      @delivery_challan ||= DeliveryChallan.find(params[:id])
    end

    def set_inquiry_so_and_inward
      @inquiry ||= Inquiry.find(params[:inquiry_id]) if params[:inquiry_id].present?
      @sales_order ||= SalesOrder.find(params[:sales_order_id]) if params[:sales_order_id].present?
      @inward_dispatch ||= InwardDispatch.find(params[:inward_dispatch_id]) if params[:inward_dispatch_id].present?
    end

    def message_fields(object)
      object.attributes.keys - %w(id inquiry_id sales_order_id ar_invoice_request_id customer_order_date
      sales_order_date customer_request_attachment customer_po_number delivery_challan_number
      created_from created_by_id updated_by_id created_at updated_at inward_dispatch_id display_gst_pan
      display_rates display_stamp)
    end

    def delivery_challan_params
      params.require(:delivery_challan).permit(
        :id,
        :inquiry_id,
        :inward_dispatch_id,
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
        :display_gst_pan,
        :display_rates,
        :display_stamp,
        :created_from,
        rows_attributes: [:id, :product_id, :sr_no, :quantity, :total_quantity, :inquiry_product_id, :sales_order_row_id, :inward_dispatch_row_id, :unit_selling_price, :_destroy]
      )
    end
end