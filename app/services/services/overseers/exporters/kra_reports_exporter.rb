class Services::Overseers::Exporters::KraReportsExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(*params)
    super(*params)
    @model = Inquiry
    @category = @params.present? ? (@params['category'] == 'company_key' ? 'Company' : 'Inside Sales') : 'Inside Sales'
    @export_name = [@params.present? ? @params['date_range'] : '', @category, 'Wise', 'Kra Report'].join(' ')
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
        'Revenue'
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
        sales_quotes: inquiry['sales_quote_count'].present? ? number_with_delimiter(inquiry['sales_quote_count']['value'].to_i, delimiter: ',') : 0,
        total_quote_value: inquiry['total_quote_value'].present? ? inquiry['total_quote_value']['value'] : 0,
        expected_orders: inquiry['expected_order'].present? ? number_with_delimiter(inquiry['expected_order']['value'].to_i, delimiter: ',') : 0,
        total_expected_orders_value: inquiry['total_order_value'].present? ? inquiry['total_order_value']['value'] : 0,
        sales_orders: inquiry['sales_order_count'].present? ? number_with_delimiter(inquiry['sales_order_count']['value'].to_i, delimiter: ',') : 0,
        total_sales_orders: inquiry['total_order_value'].present? ? inquiry['total_order_value']['value'] : 0,
        sku: inquiry['sku'].present? ? number_with_delimiter(inquiry['sku']['value'].to_i) : 0,
        inquiries_won: inquiry['order_won']['value'].to_i > 0 ? percentage(inquiry['order_won']['value'] * 100.0 / inquiry['doc_count'], show_symbol: false) : 0,
        sales_invoices: inquiry['invoices_count'].present? ? number_with_delimiter(inquiry['invoices_count']['value'].to_i, delimiter: ',') : 0,
        revenue: inquiry['revenue'].present? ? inquiry['revenue']['value'] : 0
          ) if inquiry.present?
    end
    export = Export.create!(export_type: 90, filtered: false, created_by_id: @overseer.id, updated_by_id: @overseer.id)
    generate_csv(export)
  end
end
