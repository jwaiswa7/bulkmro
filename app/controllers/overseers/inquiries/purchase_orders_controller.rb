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
    if purchase_order.metadata['PoSupNum'].present?
      product_supplier = ( Company.find_by_legacy_id(purchase_order.metadata['PoSupNum']) || Company.find_by_remote_uid(purchase_order.metadata['PoSupNum']) )
      return product_supplier if ( purchase_order.inquiry.suppliers.include?(product_supplier) || purchase_order.is_legacy? )
    end
    if purchase_order.inquiry.final_sales_quote.present?
      product_supplier = purchase_order.inquiry.final_sales_quote.rows.select {|sales_quote_row| sales_quote_row.product.id == product_id || sales_quote_row.product.legacy_id == product_id}.first
      product_supplier.supplier if product_supplier.present?
    end
  end

  def get_packing(metadata)
    if metadata['PoShippingCost'].present?
      metadata['PoShippingCost'].to_f > 0 ? (metadata['PoShippingCost'].to_f + ' Amount Extra') : 'Included'
      else
      'Included'
    end
  end

  def set_purchase_order
    @purchase_order = @inquiry.purchase_orders.find(params[:id])
  end
end

