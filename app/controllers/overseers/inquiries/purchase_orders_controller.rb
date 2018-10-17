class Overseers::Inquiries::PurchaseOrdersController < Overseers::Inquiries::BaseController
  before_action :set_purchase_order, only: [:show]

  def index
    @purchase_orders = @inquiry.purchase_orders
    authorize @purchase_orders
  end

  def show
    # @inquiry = Inquiry.find_by_inquiry_number(params[:PoEnquiryId])
    # @sales_purchase_order = SalesPurchaseOrder.create!(po_uid: params[:PoNum], inquiry: @inquiry, request_payload: params)
    #
    # @po = @sales_purchase_order.request_payload.deep_symbolize_keys
    # @supplier_billing = Address.where(remote_uid: @po[:PoSupBillFrom]).first
    # @supplier_shipping = Address.where(remote_uid: @po[:PoSupShipFrom]).first
    #
    # @po[:packing] = @po[:PoShippingCost].to_f > 0 ? @po[:PoShippingCost].to_f + ' Amount Extra' : 'Included'
    # @po[:item_subtotal] = 0
    # @po[:item_tax_amount] = 0
    # @po[:item_subtotal_incl_tax] = 0
    #
    # @po[:ItemLine].each do |item|
    #   @product = Product.find_by_sku(item[:PopProductSku])
    #   item[:uom] = @product.measurement_unit.name
    #   item[:sku] = @product.sku
    #   item[:row_total] = item[:PopPriceHt].to_f * item[:PopQty].to_f
    #   item[:tax_rate] = @product.tax_code.tax_percentage
    #   item[:tax_amount] = (item[:row_total].to_f * item[:tax_rate] / 100).round(2)
    #   item[:row_total_incl_tax] = item[:row_total].to_f + item[:tax_amount].to_f
    #   @po[:item_subtotal] += item[:row_total]
    #   @po[:item_tax_amount] += item[:tax_amount]
    #   @po[:item_subtotal_incl_tax] += item[:row_total_incl_tax]
    # end
    # @sales_purchase_order.update_attributes(request_payload: @po)

    authorize @purchase_order
    @metadata = @purchase_order.metadata.deep_symbolize_keys
    @supplier = get_supplier(@purchase_order, @purchase_order.rows.first.metadata['PopProductId'].to_i)
    respond_to do |format|
      format.html {}
      format.pdf do
        render_pdf_for @purchase_order
      end
    end
  end

  def get_supplier(purchase_order, product_id)
    product_supplier = purchase_order.inquiry.final_sales_quote.rows.select { | supplier_row |  supplier_row.product.id == product_id || supplier_row.product.legacy_id  == product_id}.first

    product_supplier.supplier if product_supplier.present?

  end

  private
  def set_purchase_order
    @purchase_order = @inquiry.purchase_orders.find(params[:id])
  end
end

