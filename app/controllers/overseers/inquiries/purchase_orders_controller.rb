class Overseers::Inquiries::PurchaseOrdersController < Overseers::Inquiries::BaseController
  before_action :set_purchase_order, only: [:show]

  def index
    @purchase_orders = @inquiry.purchase_orders
    authorize @purchase_orders
  end

  def show
    authorize @purchase_order

    @metadata = @purchase_order.metadata.deep_symbolize_keys
    @supplier = get_supplier(@purchase_order, @purchase_order.rows.first.metadata['PopProductId'].to_i)
    @metadata[:packing] = get_packing(@metadata)

    respond_to do |format|
      format.html {}
      format.pdf do
        render_pdf_for @purchase_order
      end
    end
  end

  private
  def get_supplier(purchase_order, product_id)
    product_supplier = purchase_order.inquiry.final_sales_quote.rows.select { | supplier_row |  supplier_row.product.id == product_id || supplier_row.product.legacy_id  == product_id}.first

    product_supplier.supplier if product_supplier.present?
  end

  def get_packing(metadata)
    metadata[:PoShippingCost].to_f > 0 ? metadata[:PoShippingCost].to_f + ' Amount Extra' : 'Included' if metadata[:PoShippingCost].present?
  end

  def set_purchase_order
    @purchase_order = @inquiry.purchase_orders.find(params[:id])
  end
end

