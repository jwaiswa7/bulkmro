class Services::Overseers::Exporters::CompanyReportsExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(*params)
    super(*params)
    @model = Company
    @export_name = [@date_range.present? ? @date_range : '', 'Company Report'].join(' ')
    @path = Rails.root.join('tmp', filename)
    @columns = [
        'Company Name',
        'Company Alias',
        'No. of Live Inquiries',
        'No. of Live Quotation',
        'No. of Live Expected Orders',
        'Value of Expected Orders',
        'No. of Orders',
        'Value of Orders',
        'Order Margin',
        '%Margin',
        'No of Invoices',
        'Amount Invoiced(Excl. Taxes)',
        'Invoice Margin(Excl. Taxes)',
        'Amount Outstanding(Incl. Taxes)',
        'No. of Cancelled Invoices'
    ]
  end

  def call
    perform_export_later('CompanyReportsExporter', @arguments)
  end

  def build_csv
    if @indexed_records.present?
      records = @indexed_records
    end
    records.each do |inquiry|
      rows.push(
          company_key: Company.find( inquiry['key']).name,
          account: Company.find( inquiry['key']).account.name,
          inquiries_size: Company.find( inquiry['key']).inquiry_size,
          sales_quote_count: number_with_delimiter(inquiry['sales_quotes']['value'].to_i, delimiter: ','),
          total_quote_value: format_currency(inquiry['total_sales_value']['value']),
          expected_order: number_with_delimiter(inquiry['expected_orders']['value'].to_i, delimiter: ','),
          expected_value: format_currency(inquiry['total_expected_value']['value']),
          sales_order_count: number_with_delimiter(inquiry['total_sales_orders']['value'].to_i, delimiter: ','),
          total_order_value: format_currency(inquiry['total_order_value']['value']),
          total_margin: inquiry['order_margin']['value'],
          invoices_count: percentage(inquiry['margin_percentage']['value']),
          amount_invoiced: number_with_delimiter(inquiry['sales_invoices']['value'].to_i, delimiter: ','),
          margin_percentage: format_currency(inquiry['amount_invoiced']['value']),
          cancelled_invoiced: number_with_delimiter(inquiry['cancelled_invoiced']['value'].to_i, delimiter: ','),
      ) if inquiry.present?
    end
    export = Export.create!(export_type: 91, filtered: false, created_by_id: @overseer.id, updated_by_id: @overseer.id)
    generate_csv(export)
  end
end
