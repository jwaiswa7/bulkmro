class Services::Overseers::Exporters::CompanyReportsExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(*params)
    super(*params)
    @model = Company
    @export_name = [@params.present? ? @params['date_range'] : 'Overall', 'Company Report'].join(' ')
    @path = Rails.root.join('tmp', filename)
    @columns = [
        'Company Alias',
        'Company Name',
        'Inquiries #',
        'Quotation #',
        'Value of Quotations',
        'Expected Orders #',
        'Value of Expected Orders',
        'Orders #',
        'Uniq SKUs',
        'Value of Orders',
        'Gross Margin(Assumed)',
        'Gross Margin %',
        'Invoices #',
        'Value of Invoices',
        'Gross Margin(Actual)'
    ]
  end

  def call
    perform_export_later('CompanyReportsExporter', @arguments)
  end

  def build_csv
    @export_time['creation'] = Time.now
    ExportMailer.export_notification_mail(@export_name,true,@export_time).deliver_now
    if @indexed_records.present?
      records = @indexed_records
    end
    records.each do |account|
      account['companies']['buckets'].each do |company|
        rows.push(
          account: Company.find(company['key']).account.to_s,
          company_key: Company.find(company['key']).name,
          live_inquiries: number_with_delimiter(Company.find(company['key']).inquiry_size.to_i, delimiter: ','),
          sales_quote_count: number_with_delimiter(company['sales_quotes']['value'].to_i, delimiter: ','),
          total_quote_value: format_currency(company['sales_quotes_total']['value'].to_i, precision: 0),
          expected_order: number_with_delimiter(company['expected_orders']['value'].to_i, delimiter: ','),
          expected_value: format_currency(company['expected_orders_total']['value'].to_i, precision: 0),
          sales_order_count: number_with_delimiter(company['sales_orders']['value'].to_i, delimiter: ','),
          sku: number_with_delimiter(company['sku']['value'].to_i, delimiter: ','),
          total_order_value: format_currency(company['sales_orders_total']['value'].to_i, precision: 0),
          total_margin: format_currency(company['sales_orders_margin']['value'].to_i, precision: 0),
          margin: if company['sales_orders'].present?
                    percentage(company['sales_orders_margin_percentage']['value'].to_f / company['sales_orders']['value'].to_i)
                  else
                    ''
                  end,
        invoices_count: number_with_delimiter(company['sales_invoices']['value'].to_i, delimiter: ','),
        amount_invoiced: format_currency(company['sales_invoices_total']['value'].to_i, precision: 0),
        margin_percentage: number_with_delimiter(company['sales_invoices_margin']['value'].to_i, delimiter: ',')
        ) if company.present?
      end
    end
    export = Export.create!(export_type: 91, filtered: false, created_by_id: @overseer.id, updated_by_id: @overseer.id)
    generate_csv(export)
  end
end
