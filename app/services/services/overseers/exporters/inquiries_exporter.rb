class Services::Overseers::Exporters::InquiriesExporter < Services::Overseers::Exporters::BaseExporter

  def initialize
    super

    @columns = ['inquiry_number', 'order_number', 'created_at', 'quote_type', 'opportunity_type', 'inside_sales_owner', 'ise_city', 'outside_sales_owner', 'ose_city', 'company_alias', 'company_name', 'customer', 'subject', 'currency', 'total (Exc. Tax)', 'commercial_status', 'comments', 'reason']
    @model = Inquiry
  end

  def call
    model.where(:created_at => start_at..end_at).each do |record|
      rows.push({
                       :inquiry_number => record.inquiry_number,
                       :order_number => record.sales_orders.pluck(:order_number).compact.join(','),
                       :created_at => record.created_at.to_date.to_s,
                       :quote_type => record.quote_category,
                       :opportunity_type => record.opportunity_type,
                       :inside_sales_owner => record.inside_sales_owner.to_s,
                       :ise_city => record.inside_sales_owner.geography,
                       :outside_sales_owner => record.outside_sales_owner.to_s,
                       :ose_city => record.outside_sales_owner.geography,
                       :company_alias => record.account.name,
                       :company_name => record.company.name,
                       :customer => record.contact.to_s,
                       :subject => record.subject,
                       :currency => record.currency.name,
                       :total => record.final_sales_quote.try(:calculated_total),
                       :commercial_status => record.commercial_status.to_s,
                       :comments => record.comments.pluck(:message).join(','),
                       :reason => ''
                   })
    end

    generate_csv
  end
end