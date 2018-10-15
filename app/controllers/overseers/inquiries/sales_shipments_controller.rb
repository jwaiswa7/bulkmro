class Overseers::Inquiries::SalesShipmentsController < Overseers::Inquiries::BaseController
  before_action :set_sales_shipment, only: [:show]

  def index
    @sales_shipments = @inquiry.shipments
    authorize @sales_shipments
  end

  def show
    # @sales_order = SalesOrder.find(params[:order_id])
    # @sales_shipment = SalesShipment.create!(shipment_uid: params[:increment_id], sales_order: @sales_order, request_payload: params)
    # @shipment = @sales_shipment.request_payload.deep_symbolize_keys
    # @shipment[:ItemLine].each do |item|
    #   @sales_order.rows.each do |row|
    #     if row.sales_quote_row.product.sku == item[:sku]
    #       item[:remote_name] = item[:name]
    #       item[:name] = row.sales_quote_row.to_bp_catalog_s
    #       item[:uom] = row.sales_quote_row.product.measurement_unit.name
    #       item[:hsn] = row.tax_code.chapter
    #       item[:tax_rate] = row.tax_code.tax_percentage
    #     end
    #   end
    # end
    #
    # @sales_shipment.update_attributes(request_payload: @shipment)
    #
    authorize @sales_shipment
    @metadata = @sales_shipment.metadata

    respond_to do |format|
      format.html {}
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

