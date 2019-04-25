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
          company_key: Company.find(inquiry.attributes['company_key']).name,
          account: inquiry.attributes['account'],
          inquiries_size: number_with_delimiter(inquiry.attributes['live_inquiries'].to_i, delimiter: ','),
          sales_quote_count: number_with_delimiter(inquiry.attributes['sales_quote_count'].to_i, delimiter: ','),
          total_quote_value: format_currency(inquiry.attributes['final_sales_quotes'].present? ? inquiry.attributes['final_sales_quotes'].map{|f| f['calculated_total'].to_f}.sum : 0 ),
          expected_order: number_with_delimiter(inquiry.attributes['expected_order'].present? ? inquiry.attributes['expected_order'].count : 0, delimiter: ',') ,
          expected_value:  format_currency(inquiry.attributes['expected_order'].present? ? inquiry.attributes['expected_order'].map{|f| f['calculated_total'].to_f}.sum : 0),
          sales_order_count: number_with_delimiter(inquiry.attributes['final_sales_orders'].present? ? inquiry.attributes['final_sales_orders'].count : 0, delimiter: ','),
          total_order_value: format_currency(inquiry.attributes['final_sales_orders'].present? ? inquiry.attributes['final_sales_orders'].map{|f| f['calculated_total'].to_f}.sum : 0),
          total_margin: format_currency(inquiry.attributes['final_sales_orders'].present? ? inquiry.attributes['final_sales_orders'].map{|f| f['calculated_total_margin'].to_f}.sum : 0),
          margin: if inquiry.attributes['final_sales_orders'].present?
                    percentage(inquiry.attributes['final_sales_orders'].map{|f| f['calculated_total_margin_percentage'].to_f}.sum  / inquiry.attributes['final_sales_orders'].map{|f| f['calculated_total_margin_percentage'].to_f}.count)
                  else
                    percentage(0.0)
                  end,
          invoices_count: (number_with_delimiter(inquiry.attributes['invoices'].count, delimiter: ',') if inquiry.attributes['invoices'].present?),
          amount_invoiced: format_currency(inquiry.attributes['invoices'].present? ? inquiry.attributes['invoices'].map{|f| f['calculated_total'].to_f}.sum : 0),
          margin_percentage: if inquiry.attributes['final_sales_quotes'].present?
                               percentage(inquiry.attributes['final_sales_quotes'].map{|f| f['calculated_total_margin_percentage'].to_f}.sum / inquiry.attributes['final_sales_quotes'].map{|f| f['calculated_total_margin_percentage'].to_f}.count )
                             else
                               percentage(0.0)
                             end,
          cancelled_invoiced: number_with_delimiter(inquiry.attributes['cancelled_invoiced'].to_i, delimiter: ','),
      ) if inquiry.present?
    end
    export = Export.create!(export_type: 91, filtered: false, created_by_id: @overseer.id, updated_by_id: @overseer.id)
    generate_csv(export)
  end
end
