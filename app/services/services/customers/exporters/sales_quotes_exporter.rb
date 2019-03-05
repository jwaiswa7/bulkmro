class Services::Customers::Exporters::SalesQuotesExporter < Services::Customers::Exporters::BaseExporter
  def initialize(headers, company)
    @file_name = 'sales_quotes_for_customer'
    super(headers, @file_name)
    @company = company
    @model = SalesQuote
    @columns = [
        'Inquiry Number',
        'Date',
        'Line Items',
        'Total',
        'Sales Person',
        'Valid Upto',
        'Status'
    ]
    @columns.each do |column|
      rows.push(column)
    end
  end

  def call
    build_csv
  end

  def build_csv
    sales_quote_ids = model.joins(:inquiry).where('inquiries.company_id = ? AND inquiries.created_at > ?', company.id, start_at).select('max(sales_quotes.id) as id').group(:inquiry_id).map(&:id)
    Enumerator.new do |yielder|
      yielder << CSV.generate_line(rows)
      model.where(id: sales_quote_ids).order(created_at: :desc).each do |sales_quote|
        inquiry = sales_quote.inquiry

        rows.push(
          inquiry_number: inquiry.try(:inquiry_number) || '',
          date: format_date(sales_quote.created_at),
          line_items: sales_quote.rows.size,
          total: sales_quote.calculated_total || '',
          sales_person: sales_quote.inquiry.inside_sales_owner.to_s,
          valid_upto: sales_quote.inquiry.valid_end_time || '',
          status: sales_quote.changed_status(sales_quote.inquiry.status)
                  )
      end
      rows.drop(columns.count).each do |row|
        yielder << CSV.generate_line(row.values)
      end
    end
  end
end
