class Callbacks::PdfCollectionsController < Callbacks::BaseController
  def invoice_pdf
    @invoice = params
    @sales_order = SalesOrder.find(@invoice[:order_id].to_s)

    @invoice[:ItemLine].each do |item|
      @sales_order.rows.each do |row|
        if row.sales_quote_row.product.sku == item[:sku]
          item[:uom] = row.sales_quote_row.product.measurement_unit.name
          item[:hsn] = row.tax_code.chapter
          item[:tax_rate] = row.tax_code.tax_percentage
        end
      end
    end

    respond_to do |format|
      format.pdf do
      render  pdf: 'invoice #{@invoice[:increment_id].to_s}',
            # show_as_html: true,
            template: 'callbacks/pdf_collections/invoice',
            layout: 'overseers/layouts/pdf.html.erb',
            footer: {center: '[page] of [topage]'}
      end
    end
  end

  def shipment_pdf
    @shipment = params
    @sales_order = SalesOrder.find(@shipment[:order_id].to_s)

    @shipment[:ItemLine].each do |item|
      @sales_order.rows.each do |row|
        if row.sales_quote_row.product.sku == item[:sku]
          item[:uom] = row.sales_quote_row.product.measurement_unit.name
          item[:hsn] = row.tax_code.chapter
        end
      end
    end

    respond_to do |format|
      format.pdf do
      render  pdf: 'shipment #{@shipment[:increment_id].to_s}',
            # show_as_html: true,
            template: 'callbacks/pdf_collections/shipment',
            layout: 'overseers/layouts/pdf.html.erb',
            footer: {center: '[page] of [topage]'}
      end
    end
  end

  def po_pdf
    @po = params
    # raise
    @inquiry = Inquiry.find(@po[:PoEnquiryId].to_s)

    @po[:item_subtotal] = 0
    @po[:item_tax_amount] = 0
    @po[:item_subtotal_incl_tax] = 0

    @po[:ItemLine].each do |item|
      @product = Product.find_by_legacy_id(item[:PopProductId].to_s)
      puts "hhhshhshs"
      puts @po[:PopProductId].to_s
      item[:uom] = @product.measurement_unit.name
      item[:sku] = @product.sku #row.tax_code.chapter
      item[:row_total] = item[:PopPriceHt].to_f * item[:PopQty].to_f
      item[:tax_rate] = @product.tax_code.tax_percentage
      item[:tax_amount] = (item[:row_total].to_f * item[:tax_rate] / 100).round(2)
      item[:row_total_incl_tax] = item[:row_total].to_f + item[:tax_amount].to_f
      @po[:item_subtotal] += item[:row_total]
      @po[:item_tax_amount] += item[:tax_amount]
      @po[:item_subtotal_incl_tax] += item[:row_total_incl_tax]
    end

    respond_to do |format|
      format.pdf do
      render  pdf: 'po #{@po[:increment_id].to_s}',
            # show_as_html: true,
            template: 'callbacks/pdf_collections/po',
            layout: 'overseers/layouts/pdf.html.erb',
            footer: {center: '[page] of [topage]'}
      end
    end
  end

end