class Services::Customers::Exporters::SalesOrdersExporter < Services::Customers::Exporters::BaseExporter
  def initialize(headers, company)
    @file_name = 'sales_orders_for_customer'
    super(headers, @file_name)
    @company = company
    @model = SalesOrder
    @columns = [
        'Inquiry Number',
        'Order Number',
        'Order Date',
        'Mis Date',
        'Company Name',
        'Company Alias',
        'Order Net Amount',
        'Order Tax Amount',
        'Order Total Amount',
        'Order Status'
    ]
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
      model.remote_approved.where.not(sales_quote_id: nil).joins(:inquiry).where('inquiries.company_id = ?', company.id).where(mis_date: start_at..end_at).order(mis_date: :desc).each do |sales_order|
        inquiry = sales_order.inquiry

        rows.push(
          inquiry_number: inquiry.try(:inquiry_number) || '',
          order_number: sales_order.order_number,
          order_date: sales_order.created_at.to_date.to_s,
          mis_date: sales_order.mis_date.to_date.to_s,
          company_alias: inquiry.try(:account).try(:name),
          company_name: inquiry.try(:company).try(:name) ? inquiry.try(:company).try(:name).gsub(/;/, ' ') : '',
          gt_exc: (sales_order.calculated_total == 0) ? (sales_order.calculated_total == nil ? 0 : '%.2f' % sales_order.calculated_total) : ('%.2f' % sales_order.calculated_total),
          tax_amount: ('%.2f' % sales_order.calculated_total_tax if sales_order.inquiry.present?),
          gt_inc: ('%.2f' % sales_order.calculated_total_with_tax if sales_order.inquiry.present?),
          status: sales_order.remote_status,
                  ) if inquiry.present?
      end
      rows.drop(columns.count).each do |row|
        yielder << CSV.generate_line(row.values)
      end
    end
  end
end
