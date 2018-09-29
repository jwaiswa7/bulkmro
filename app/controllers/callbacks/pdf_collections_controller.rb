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

    # respond_to do |format|
    #   format.pdf do
    render  pdf: 'invoice #{@invoice[:increment_id].to_s}',
            # show_as_html: true,
            template: 'callbacks/pdf_collections/invoice',
            footer: {center: '[page] of [topage]'}
    #   end
    # end
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

    # respond_to do |format|
    #   format.pdf do
    render  pdf: 'shipment #{@shipment[:increment_id].to_s}',
            # show_as_html: true,
            template: 'callbacks/pdf_collections/shipment',
            footer: {center: '[page] of [topage]'}
    #   end
    # end
  end

end