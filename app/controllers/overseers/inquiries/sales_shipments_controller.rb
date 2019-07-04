class Overseers::Inquiries::SalesShipmentsController < Overseers::Inquiries::BaseController
  before_action :set_sales_shipment, only: [:show, :relationship_map, :get_relationship_map_json]

  def index
    @sales_shipments = @inquiry.shipments
    authorize_acl @sales_shipments
  end

  def show
    authorize_acl @sales_shipment
    @metadata = @sales_shipment.metadata.present? ? @sales_shipment.metadata.deep_symbolize_keys : nil
    if @metadata.nil?
      set_flash_message('There is no information to show for this Sales Shipment', :warning, now: false)
      redirect_to(request.referrer || root_path)
    end

    respond_to do |format|
      format.html { }
      format.pdf do
        render_pdf_for @sales_shipment
      end
    end
  end

  def relationship_map
    authorize_acl @sales_shipment
  end

  def get_relationship_map_json
    authorize_acl @sales_shipment
    inquiry_json = Services::Overseers::Inquiries::RelationshipMap.new(@sales_shipment.inquiry, [@sales_shipment.sales_order.sales_quote]).call
    render json: {data: inquiry_json}
  end

  private
    def set_sales_shipment
      @sales_shipment = @inquiry.shipments.find(params[:id])
    end
end
