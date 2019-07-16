class Overseers::Inquiries::PurchaseOrdersController < Overseers::Inquiries::BaseController
  before_action :set_purchase_order, only: [:show, :relationship_map, :get_relationship_map_json]
  before_action :set_purchase_order_items, only: [:show]

  def index
    @purchase_orders = @inquiry.purchase_orders
    authorize_acl @purchase_orders
  end

  def show
    authorize_acl @purchase_order
    @metadata = @purchase_order.metadata.deep_symbolize_keys
    @payment_terms = PaymentOption.find_by(remote_uid: @metadata[:PoPaymentTerms])
    @supplier = get_supplier(@purchase_order, @purchase_order.rows.first.metadata['PopProductId'].to_i)
    @metadata[:packing] = get_packing(@metadata)

    respond_to do |format|
      format.html {render 'show'}
      format.pdf do
        render_pdf_for(@purchase_order, locals: {inquiry: @inquiry, purchase_order: @purchase_order, metadata: @metadata, supplier: @supplier, payment_terms: @payment_terms, payment_terms: @payment_terms})
      end
    end
  end

  def relationship_map
    authorize_acl @inquiry
  end

  def get_relationship_map_json
    authorize_acl @purchase_order
    purchase_order = PurchaseOrder.joins(po_request: :sales_order).where(purchase_orders: {id: @purchase_order.id}).where.not(po_requests: {id: nil}).select('sales_orders.id as sales_order_id')

    if purchase_order.present? && purchase_order.first.sales_order_id.present?
      sales_order = SalesOrder.find(purchase_order.first.sales_order_id)
      inquiry_json = Services::Overseers::Inquiries::RelationshipMap.new(sales_order.inquiry, [sales_order.sales_quote]).call if sales_order.present?
    else
      purchase_order = @purchase_order if purchase_order.blank?
      if purchase_order.present? && purchase_order.inquiry.present?
        inquiry_json = Services::Overseers::Inquiries::RelationshipMap.new(purchase_order.inquiry, [], [purchase_order]).call
      end
    end
    render json: {data: inquiry_json}
  end

  private

  def set_purchase_order
    @purchase_order = @inquiry.purchase_orders.find(params[:id])
  end

  def get_supplier(purchase_order, product_id)
    if purchase_order.metadata['PoSupNum'].present?
      product_supplier = (Company.find_by_remote_uid(purchase_order.metadata['PoSupNum']) || Company.find_by_legacy_id(purchase_order.metadata['PoSupNum']))
      return product_supplier if purchase_order.inquiry.suppliers.include?(product_supplier) || purchase_order.is_legacy?
    else
      if purchase_order.inquiry.final_sales_quote.present?
        product_supplier = purchase_order.inquiry.final_sales_quote.rows.select {|sales_quote_row| sales_quote_row.product.id == product_id || sales_quote_row.product.legacy_id == product_id}.first
        product_supplier.supplier if product_supplier.present?
      end
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

  def set_purchase_order_items
    Resources::PurchaseOrder.set_multiple_items([@purchase_order.po_number])
  end
end
