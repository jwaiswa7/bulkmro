

class Overseers::Inquiries::SalesShipmentsController < Overseers::Inquiries::BaseController
  before_action :set_sales_shipment, only: [:show]

  def index
    @sales_shipments = @inquiry.shipments
    authorize @sales_shipments
  end

  def show
    authorize @sales_shipment
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

  private
    def set_sales_shipment
      @sales_shipment = @inquiry.shipments.find(params[:id])
    end
end
