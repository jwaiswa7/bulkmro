class Services::Overseers::Exporters::InquiriesExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(headers)
    @file_name = 'inquiries'
    super(headers, @file_name)
    @model = Inquiry
    @columns = ['inquiry_number', 'order_number', 'created_at', 'customer_committed_date', 'updated_at', 'quote_type', 'status', 'opportunity_type', 'inside_sales_owner', 'ise_city', 'outside_sales_owner', 'ose_city', 'company_alias', 'company_name', 'customer', 'subject', 'currency', 'potential amount', 'total (Exc. Tax)', 'comments', 'reason']
    @start_at = Date.new(2018, 04, 01)
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
      model.where(created_at: start_at..end_at).order(created_at: :desc).each do |record|
        rows.push(
                      inquiry_number: record.inquiry_number,
                      order_number: record.sales_orders.pluck(:order_number).compact.join(','),
                      created_at: record.created_at.to_date.to_s,
                      committed_customer_date: ( record.customer_committed_date.present? ? record.customer_committed_date.to_date.to_s : nil ),
                      updated_at: record.updated_at.to_date.to_s,
                      quote_type: record.quote_category,
                      status: record.status,
                      opportunity_type: record.opportunity_type,
                      inside_sales_owner: record.inside_sales_owner.try(:full_name),
                      ise_city: record.inside_sales_owner.try(:geography),
                      outside_sales_owner: record.outside_sales_owner.try(:full_name),
                      ose_city: record.outside_sales_owner.try(:geography),
                      company_alias: record.account.try(:name),
                      company_name: record.company.try(:name),
                      customer: record.contact.to_s,
                      subject: record.subject,
                      currency: record.currency.try(:name),
                      potential_amount: record.potential_amount,
        total: record.final_sales_quote.try(:calculated_total),
                      comments: record.comments.pluck(:message).join(','),
                      reason: ''
                  )
      end
      rows.drop(columns.count).each do |row|
        yielder << CSV.generate_line(row.values)
      end
    end
  end
end
