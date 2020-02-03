class Suppliers::PurchaseOrdersController < Suppliers::BaseController
  before_action :set_purchase_order, only: [:show]

  def index
    authorize :purchase_order

    respond_to do |format|
      format.html { }
      format.json do
        service = Services::Suppliers::Finders::PurchaseOrders.new(params, current_suppliers_contact, current_company)
        service.call

        @indexed_purchase_orders = service.indexed_records
        @purchase_orders = service.records.try(:reverse)
      end
    end
  end

  def show
    authorize @purchase_order

    @metadata = @purchase_order.metadata.deep_symbolize_keys
    @payment_terms = PaymentOption.find_by(remote_uid: @metadata[:PoPaymentTerms])
    @inquiry = @purchase_order.inquiry
    if @purchase_order.supplier.present?
      @supplier = @purchase_order.supplier
    else
      @supplier = get_supplier(@purchase_order, @purchase_order.rows.first.metadata['PopProductId'].to_i)
    end

    @metadata[:packing] = get_packing(@metadata)

    respond_to do |format|
      format.html {render 'show'}
      format.pdf do
        render_pdf_for(@purchase_order, locals: {inquiry: @inquiry, purchase_order: @purchase_order, metadata: @metadata, supplier: @supplier, payment_terms: @payment_terms, payment_terms: @payment_terms})
      end
    end
  end

  private
    def set_purchase_order
      @purchase_order = PurchaseOrder.find(params[:id])
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
end
