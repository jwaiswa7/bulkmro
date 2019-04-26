class Services::Overseers::Exporters::KraReportsExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(*params)
    super(*params)
    @model = Inquiry
    @category = @params.present? ? (@params['category'] == 'company_key' ? 'Company' : 'Inside Sales') : 'Inside Sales'
    @export_name = [@params.present? ? @params['date_range'] : '', @category , 'Wise','Kra Report'].join(' ')
    @path = Rails.root.join('tmp', filename)
    @columns = [
         @category,
        'No. of Inquiries',
        'No. of Sales Quotes',
        'Value of Quotes',
        'No. of Expected Orders',
        'Value of Expected Orders',
        'No. of Sales Orders',
        'Value of Orders',
        'Unique ordered #SKU',
        '% Inquiries Won',
        'No. of Sales Invoices',
        'Revenue',
        'Client'
    ]
  end

  def call
    perform_export_later('KraReportsExporter', @arguments)
  end

  def build_csv
    if @indexed_records.present?
      records = @indexed_records
    end
    records.each do |inquiry|
      rows.push(
        inside_sales: (@category == 'Company') ? Company.find(inquiry['key']).to_s : Overseer.find(inquiry['key']).to_s,
        inquiries: number_with_delimiter(inquiry['doc_count'], delimiter: ','),
        sales_quotes: number_with_delimiter(inquiry['sales_quotes']['value'].to_i, delimiter: ','),
        total_quote_value: format_currency(inquiry['total_sales_value']['value']),
        expected_orders: number_with_delimiter(inquiry['expected_orders']['value'].to_i, delimiter: ','),
        total_expected_orders_value: format_currency(inquiry['total_order_value']['value']),
        sales_orders: number_with_delimiter(inquiry['sales_orders']['value'].to_i, delimiter: ','),
        total_sales_orders: format_currency(inquiry['total_sales_value']['value']),
        sku: number_with_delimiter(inquiry['sku']['value'].to_i),
        inquiries_won: inquiry['orders_won']['value'] > 0 ? percentage(inquiry['orders_won']['value'] * 100.0 / inquiry['doc_count']) : '-',
        sales_invoices: number_with_delimiter(inquiry['sales_invoices']['value'].to_i, delimiter: ','),
        revenue: format_currency(inquiry['revenue']['value']),
        clients: number_with_delimiter(inquiry['clients']['value'].to_i, delimiter: ',')
          ) if inquiry.present?
    end
    export = Export.create!(export_type: 90, filtered: false, created_by_id: @overseer.id, updated_by_id: @overseer.id)
    generate_csv(export)
  end
end
