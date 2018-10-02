class Callbacks::PdfCollectionsController < Callbacks::BaseController
  def invoice_pdf
    save_invoice

    respond_to do |format|
      format.pdf do
      render  pdf: 'invoice #{@invoice[:increment_id].to_s}',
            template: 'callbacks/pdf_collections/invoice',
            layout: 'overseers/layouts/sap',
            footer: {center: '[page] of [topage]'}
      end
    end
  end

  def shipment_pdf
    save_shipment

    respond_to do |format|
      format.pdf do
      render  pdf: 'shipment #{@shipment[:increment_id].to_s}',
            template: 'callbacks/pdf_collections/shipment',
            layout: 'overseers/layouts/sap',
            footer: {center: '[page] of [topage]'}
      end
    end
  end

  def po_pdf
    save_purchase_order

    respond_to do |format|
      format.pdf do
      render  pdf: 'po #{@po[:increment_id].to_s}',
            template: 'callbacks/pdf_collections/po',
            layout: 'overseers/layouts/sap',
            footer: {center: '[page] of [topage]'}
      end
    end

  end

  private

  def save_invoice
    inv = SalesInvoice.new
    inv.invoice_uid = params[:increment_id]
    inv.sales_order_id = params[:order_id]
    inv.request_payload = params
    inv.save

    @sales_order = inv.sales_order
    @invoice = inv.request_payload.deep_symbolize_keys
    @invoice[:ItemLine].each do |item|
      @sales_order.rows.each do |row|
        if row.sales_quote_row.product.sku == item[:sku]
          item[:uom] = row.sales_quote_row.product.measurement_unit.name
          item[:hsn] =  @sales_order.sales_quote.is_sez ? row.tax_code.chapter : row.tax_code.code
          item[:tax_rate] = row.tax_code.tax_percentage
        end
      end
    end

  end

  def save_shipment
    ship = SalesShipment.new
    ship.shipment_uid= params[:increment_id]
    ship.sales_order_id = params[:order_id]
    ship.request_payload = params
    ship.save

    @sales_order = ship.sales_order
    @shipment = ship.request_payload.deep_symbolize_keys

    @shipment[:ItemLine].each do |item|
      @sales_order.rows.each do |row|
        if row.sales_quote_row.product.sku == item[:sku]
          item[:uom] = row.sales_quote_row.product.measurement_unit.name
          item[:hsn] = row.tax_code.chapter
        end
      end
    end

  end


  def save_purchase_order
    purchase = SalesPurchaseOrder.new
    purchase.po_uid = params[:PoNum]
    purchase.inquiry_id = params[:PoEnquiryId]
    purchase.request_payload = params
    purchase.save

    @inquiry = purchase.inquiry
    if params[:PoTargetWarehouse].present?
      @warehouse = Warehouse.find(params[:PoTargetWarehouse])
    end
    @po = purchase.request_payload.deep_symbolize_keys
    @supplier_billing = Address.find_by_legacy_id(@po[:PoSupBillFrom])
    @supplier_shipping = Address.find_by_legacy_id(@po[:PoSupShipFrom])

    @po[:packing] = @po[:PoShippingCost].to_f > 0 ? @po[:PoShippingCost].to_f + ' Amount Extra' : 'Included'

    @po[:item_subtotal] = 0
    @po[:item_tax_amount] = 0
    @po[:item_subtotal_incl_tax] = 0

    @po[:ItemLine].each do |item|
      @product = Product.find_by_legacy_id(item[:PopProductId].to_s)
      item[:uom] = @product.measurement_unit.name
      item[:sku] = @product.sku
      item[:row_total] = item[:PopPriceHt].to_f * item[:PopQty].to_f
      item[:tax_rate] = @product.tax_code.tax_percentage
      item[:tax_amount] = (item[:row_total].to_f * item[:tax_rate] / 100).round(2)
      item[:row_total_incl_tax] = item[:row_total].to_f + item[:tax_amount].to_f
      @po[:item_subtotal] += item[:row_total]
      @po[:item_tax_amount] += item[:tax_amount]
      @po[:item_subtotal_incl_tax] += item[:row_total_incl_tax]
    end

  end

end