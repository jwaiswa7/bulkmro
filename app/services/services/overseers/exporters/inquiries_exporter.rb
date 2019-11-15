class Services::Overseers::Exporters::InquiriesExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(*params)
    super(*params)
    @model = Inquiry
    @export_name = 'inquiries'
    @path = Rails.root.join('tmp', filename)
    @columns = ['inquiry_number', 'order_number', 'created_at', 'customer_committed_date', 'updated_at', 'quote_type', 'quote_date', 'status', 'opportunity_type', 'inside_sales_owner', 'ise_city', 'outside_sales_owner', 'ose_city', 'company_alias', 'company_name', 'customer', 'subject', 'currency', 'potential amount', 'total (Exc. Tax)', 'comments', 'reason', 'customer_order_date', 'customer_po_number']
    @start_at = Date.new(2018, 04, 01)
    @export.update_attributes(export_type: 1, status: 'Enqueued')
  end
  def call
    perform_export_later('InquiriesExporter', @arguments)
  end
  def build_csv
    if @ids.present?
      records = model.where(id: @ids).order(created_at: :desc)
    else
      records = model.where(created_at: start_at..end_at).order(created_at: :desc)
    end
    @export.update_attributes(export_type: 1, status: 'Processing')
    records.each do |record|
      rows.push(
          inquiry_number: record.inquiry_number,
          order_number: record.sales_orders.pluck(:order_number).compact.join(','),
          created_at: record.created_at.to_date.to_s,
          committed_customer_date: (record.customer_committed_date.present? ? record.customer_committed_date.to_date.to_s : nil),
          updated_at: record.updated_at.to_date.to_s,
          quote_type: record.quote_category,
          quote_date: record.quotation_date.present? ? record.quotation_date : '-',
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
          reason: '',
          customer_order_date: record.customer_order_date,
          customer_po_number: record.customer_po_number
      )
    end
    # filtered = @ids.present?
    @export.update_attributes(export_type: 1, status: 'Completed')
    generate_csv(@export)
  end
end