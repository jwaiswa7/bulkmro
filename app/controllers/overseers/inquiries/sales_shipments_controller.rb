class Overseers::Inquiries::SalesShipmentsController < Overseers::Inquiries::BaseController
  before_action :set_sales_shipment, only: [:show]

  def index
    @sales_shipments = @inquiry.shipments
    authorize @sales_shipments
  end

  def show
    authorize @sales_shipment
  end
end

