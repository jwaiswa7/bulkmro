class Services::Overseers::Exporters::CompanyReportsExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(*params)
    super(*params)
    @model = Company
    @export_name = [@params.present? ? @params['date_range'] : 'Overall', 'Company Report'].join(' ')
    @path = Rails.root.join('tmp', filename)
    @columns = [
        'Company Name',
        'Company Alias',
        'No. of Live Inquiries',
        'No. of Live Quotation',
        'Value of Quotations',
        'No. of Live Expected Orders',
        'Value of Expected Orders',
        'No. of Orders',
        'Value of Orders',
        'Order Margin',
        '%Margin',
        'No of Invoices',
        'Amount Invoiced(Excl. Taxes)',
        'Invoice Margin(Excl. Taxes)',
        'No. of Cancelled Invoices',
        'Value of Cancelled Invoices(Excl. Taxes)',
        'Uniq SKUs'
    ]
  end

  def call
    perform_export_later('CompanyReportsExporter', @arguments)
  end

  def build_csv
    if @indexed_records.present?
      records = @indexed_records
    end
    records.each do |company|
      rows.push(
        company_key: Company.find(company['key']).name,
        account: Company.find(company['key']).account.to_s,
        live_inquiries: number_with_delimiter(Company.find(company['key']).inquiry_size.to_i, delimiter: ','),
        sales_quote_count: number_with_delimiter(company['sales_quotes']['value'].to_i, delimiter: ','),
        total_quote_value: format_currency(company['sales_quotes_total']['value'].to_i, precision: 0),
        expected_order: number_with_delimiter(company['expected_orders']['value'].to_i, delimiter: ','),
        expected_value: format_currency(company['expected_orders_total']['value'].to_i, precision: 0),
        sales_order_count: number_with_delimiter(company['sales_orders']['value'].to_i, delimiter: ','),
        total_order_value: format_currency(company['sales_orders_total']['value'].to_i, precision: 0),
        total_margin: format_currency(company['sales_orders_margin']['value'].to_i, precision: 0),
        margin: if company['sales_orders'].present?
                  percentage(company['sales_orders_margin_percentage']['value'].to_f / company['sales_orders']['value'].to_i)
                else
                  percentage(0.0)
                end,
        invoices_count: number_with_delimiter(company['sales_invoices']['value'].to_i, delimiter: ','),
        amount_invoiced: format_currency(company['sales_invoices_total']['value'].to_i, precision: 0),
        margin_percentage: if company['sales_quotes'].present?
                             percentage(company['sales_quotes_margin_percentage']['value'].to_f / company['sales_quotes']['value'].to_i)
                           else
                             percentage(0.0)
                           end,
        cancelled_invoiced: number_with_delimiter(company['cancelled_invoiced']['value'].to_i, delimiter: ','),
        cancelled_invoiced_value: format_currency(company['cancelled_invoiced_total']['value'].to_i, precision: 0),
        sku: number_with_delimiter(company['sku']['value'].to_i, delimiter: ','),
      ) if company.present?
    end
    export = Export.create!(export_type: 91, filtered: false, created_by_id: @overseer.id, updated_by_id: @overseer.id)
    generate_csv(export)
  end
end
