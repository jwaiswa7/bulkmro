class Services::Customers::Exporters::SalesOrdersExporter < Services::Customers::Exporters::BaseExporter
  def initialize(headers, company)
    @file_name = 'sales_orders_for_customer'
    super(headers, @file_name)
    @company = company
    @model = SalesOrder
    if company.id == 1847
      @columns = ['Order Date', 'Order ID', 'PO Number', 'Part Number', 'Account Gp', 'Line Item Quantity', 'Line Item Net Total', 'Order Status', 'Account User Email', 'Shipping Address', 'Currency', 'Product Category', 'Part number Description']
    else
      @columns = ['Inquiry Number', 'Order Number', 'Order Date', 'Company Name', 'Company Alias', 'Order Net Amount', 'Order Tax Amount', 'Order Total Amount', 'Order Status']
    end
    @columns.each do |column|
      rows.push(column)
    end
  end

  def call
    build_csv
  end

  def build_csv
    Enumerator.new do |yielder|
      yielder << CSV.generate_line(rows)
      if company.id == 1847
        model.remote_approved.joins(:company).where(companies: {id: 1847}).order(name: :asc).each do |order|
          order.rows.each do |record|
            sales_order = record.sales_order
            rows.push(
              order_date: sales_order.inquiry.customer_order_date.strftime('%F'),
              order_id: sales_order.inquiry.customer_order.present? ? sales_order.inquiry.customer_order.online_order_number : '',
              customer_po_number: sales_order.inquiry.customer_po_number,
              part_number: record.product.sku,
              account: sales_order.inquiry.company.name,
              line_item_quantity: record.quantity,
              line_item_net_total: record.total_selling_price.to_s,
              sap_status: sales_order.remote_status,
              user_email: sales_order.inquiry.customer_order.present? ? sales_order.inquiry.customer_order.contact.email : 'sivakumar.ramu@flex.com',
              shipping_address: sales_order.inquiry.shipping_address,
              currency: sales_order.inquiry.inquiry_currency.currency.name,
              category: record.product.category.name,
              part_number_description: record.product.name
            )
          end
        end
      else
        model.remote_approved.where.not(sales_quote_id: nil).joins(:inquiry).where('inquiries.company_id = ?', company.id).where(mis_date: start_at..end_at).order(mis_date: :desc).each do |sales_order|
          inquiry = sales_order.inquiry

          rows.push(
            inquiry_number: inquiry.try(:inquiry_number) || '',
            order_number: sales_order.order_number,
            order_date: sales_order.created_at.to_date.to_s,
            company_name: inquiry.try(:company).try(:name) ? inquiry.try(:company).try(:name).gsub(/;/, ' ') : '',
            company_alias: inquiry.try(:account).try(:name),
            gt_exc: (sales_order.calculated_total == 0) ? (sales_order.calculated_total == nil ? 0 : '%.2f' % sales_order.calculated_total) : ('%.2f' % sales_order.calculated_total),
            tax_amount: ('%.2f' % sales_order.calculated_total_tax if sales_order.inquiry.present?),
            gt_inc: ('%.2f' % sales_order.calculated_total_with_tax if sales_order.inquiry.present?),
            status: sales_order.remote_status,
              ) if inquiry.present?
        end
      end
      rows.drop(columns.count).each do |row|
        yielder << CSV.generate_line(row.values)
      end
    end
  end
end
