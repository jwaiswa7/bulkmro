class Callbacks::PdfCollectionsController < Callbacks::BaseController
  def invoice_pdf
    save_invoice
    respond_to do |format|
      format.pdf do
      render  pdf: 'invoice_' + @sales_invoice.invoice_uid.to_s,
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
      render  pdf: 'shipment_' + @sales_shipment.shipment_uid.to_s,
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
      render  pdf: 'po_' + @po[:increment_id].to_s,
            template: 'callbacks/pdf_collections/po',
            layout: 'overseers/layouts/sap',
            footer: {center: '[page] of [topage]'}
      end
    end
  end

  private

  def save_invoice
    @sales_order = SalesOrder.find(params[:order_id])
    @sales_invoice = SalesInvoice.create!(invoice_uid: params[:increment_id], sales_order: @sales_order, request_payload: params)
    @invoice = @sales_invoice.request_payload.deep_symbolize_keys
    @invoice[:ItemLine].each do |item|
      @sales_order.rows.each do |row|
        if row.sales_quote_row.product.sku == item[:sku]
          item[:remote_name] = item[:name]
          item[:name] = row.sales_quote_row.to_bp_catalog_s
          item[:uom] = row.sales_quote_row.product.measurement_unit.name
          item[:hsn] =  @sales_order.sales_quote.is_sez ? row.tax_code.chapter : row.tax_code.code
          item[:tax_rate] = row.tax_code.tax_percentage
        end
      end
    end
    @sales_invoice.update_attributes(request_payload: @invoice)
  end

  def save_shipment
    @sales_order = SalesOrder.find(params[:order_id])
    @sales_shipment = SalesShipment.create!(shipment_uid: params[:increment_id], sales_order: @sales_order, request_payload: params)
    @shipment = @sales_shipment.request_payload.deep_symbolize_keys
    @shipment[:ItemLine].each do |item|
      @sales_order.rows.each do |row|
        if row.sales_quote_row.product.sku == item[:sku]
          item[:remote_name] = item[:name]
          item[:name] = row.sales_quote_row.to_bp_catalog_s
          item[:uom] = row.sales_quote_row.product.measurement_unit.name
          item[:hsn] = row.tax_code.chapter
          item[:tax_rate] = row.tax_code.tax_percentage
        end
      end
    end
    @sales_shipment.update_attributes(request_payload: @shipment)
  end


  def save_purchase_order
    @inquiry = Inquiry.find_by_inquiry_number(params[:PoEnquiryId])
    @sales_purchase_order = SalesPurchaseOrder.create!(po_uid: params[:PoNum], inquiry: @inquiry, request_payload: params)

    @po = @sales_purchase_order.request_payload.deep_symbolize_keys
    @supplier_billing = Address.where(remote_uid: @po[:PoSupBillFrom]).first
    @supplier_shipping = Address.where(remote_uid: @po[:PoSupShipFrom]).first

    @po[:packing] = @po[:PoShippingCost].to_f > 0 ? @po[:PoShippingCost].to_f + ' Amount Extra' : 'Included'
    @po[:item_subtotal] = 0
    @po[:item_tax_amount] = 0
    @po[:item_subtotal_incl_tax] = 0

    @po[:ItemLine].each do |item|
      @product = Product.find_by_sku(item[:PopProductSku])
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
    @sales_purchase_order.update_attributes(request_payload: @po)
  end
end