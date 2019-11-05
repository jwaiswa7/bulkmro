class Services::Shared::Migrations::InquiryExport < Services::Shared::Migrations::Migrations
  def export_inquiries
    inquiry_dump = "#{Rails.root}/tmp/inquiries.csv"
    headers = ['inquiry_number', 'order_number', 'created_at', 'customer_committed_date', 'updated_at', 'quote_type', 'quote_date', 'status', 'opportunity_type', 'inside_sales_owner', 'ise_city', 'outside_sales_owner', 'ose_city', 'company_alias', 'company_name', 'customer', 'subject', 'currency', 'potential amount', 'total (Exc. Tax)', 'comments', 'reason', 'customer_order_date', 'customer_po_number']
    csv_data = CSV.generate(write_headers: true, headers: headers) do |writer|
      Inquiry.all.each do |record|
        writer << [ record.inquiry_number,
            record.sales_orders.pluck(:order_number).compact.join(','),
            record.created_at.to_date.to_s,
            (record.customer_committed_date.present? ? record.customer_committed_date.to_date.to_s : nil),
            record.updated_at.to_date.to_s,
            record.quote_category,
            record.quotation_date.present? ? record.quotation_date : '-',
            record.status,
            record.opportunity_type,
            record.inside_sales_owner.try(:full_name),
            record.inside_sales_owner.try(:geography),
            record.outside_sales_owner.try(:full_name),
            record.outside_sales_owner.try(:geography),
            record.account.try(:name),
            record.company.try(:name),
            record.contact.to_s,
            record.subject,
            record.currency.try(:name),
            record.potential_amount,
            record.final_sales_quote.try(:calculated_total),
            record.comments.pluck(:message).join(','),
            '',
            record.customer_order_date,
            record.customer_po_number ]
      end
    end
    temp_file = File.open(inquiry_dump, 'wb')
    temp_file.write(csv_data)
    temp_file.close
  end
end