class Services::Overseers::Exporters::SalesOrdersBibleFormatExporter < Services::Overseers::Exporters::BaseExporter
  def initialize
    super
    @model = SalesOrderRow
    @export_name = 'sales_order_rows_bible_format'
    @path = Rails.root.join('tmp', filename)
    @columns = [
        'Inside Sales Name',
        'Client Order #',
        'Client Order Date',
        'Price Currency',
        'Document Rate',
        'Magento Company Name',
        'Company Alias',
        'Inquiry Number',
        'So #',
        'Order Date',
        'Bm #',
        'Description',
        'Order Qty',
        'Unit Selling Price',
        'Freight',
        'Tax Type',
        'Tax Rate',
        'Tax Amount',
        'Total Selling Price',
        'Total Landed Cost',
        'Unit cost price',
        'Margin',
        'Margin (In %)',
        'So Month Code'
    ]
  end

  def call
    perform_export_later('SalesOrdersBibleFormatExporter')
  end

  def build_csv
    @export_time['creation'] = Time.now
    ExportMailer.export_notification_mail(@export_name,true,@export_time).deliver_now
    model.joins(:sales_order).where('sales_orders.status = ?', SalesOrder.statuses['Approved']).where.not('sales_orders.order_number': nil).where.not('sales_orders.sales_quote_id': nil).where(created_at: start_at..end_at).order(created_at: :desc).find_each(batch_size: 100) do |row|
      sales_order = row.sales_order
      inquiry = sales_order.inquiry

      rows.push(
        inside_sales: inquiry.inside_sales_owner.try(:full_name),
        client_order: inquiry.customer_po_number,
        client_order_date: (inquiry.customer_order_date.to_date.to_s if inquiry.customer_order_date.present?),
        currency: inquiry.currency.name,
        conversion_rate: inquiry.inquiry_currency.conversion_rate,
        company_name: inquiry.company.name,
        alias_name: inquiry.company.account.name,
        inquiry_number: inquiry.inquiry_number,
        order_number: sales_order.order_number,
        order_date: sales_order.created_at.to_date.to_s,
        bm_number: row.product.sku,
        description: row.product.name,
        qty: row.quantity,
        unit_price: row.unit_selling_price,
        freight: row.freight_cost_subtotal,
        tax_type: (sales_order.sales_quote.tax_summary.strip == '0' || sales_order.sales_quote.tax_summary.to_s.include?("IGST")) ? "IGST #{row.sales_quote_row.try(:tax_rate).try(:tax_percentage)}" : "CGST + SGST #{row.sales_quote_row.try(:tax_rate).try(:tax_percentage)}",
        tax_rate: row.sales_quote_row.try(:tax_rate).try(:tax_percentage),
        tax_amount: row.calculated_tax,
        total_selling_price: row.total_selling_price,
        total_landed_cost: row.sales_quote_row.unit_cost_price * row.quantity,
        buying_rate: row.sales_quote_row.unit_cost_price,
        margin: row.total_margin,
        margin_percentage: row.margin_percentage,
        so_month_code: ''
      )
    end
    export = Export.create!(export_type: 100)
    generate_csv(export)
  end
end