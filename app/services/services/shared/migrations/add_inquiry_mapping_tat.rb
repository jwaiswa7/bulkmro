class Services::Shared::Migrations::AddInquiryMappingTat < Services::Shared::Migrations::Migrations
  def add_inquiry_mapping_tats
    start_date = Date.parse('01-01-2019')
    end_date = Date.today
    inquiries = Inquiry.where(created_at: start_date..end_date).where.not(status: 'Expected Order').includes(:sales_orders)
    Chewy.strategy(:bypass) do
      inquiries.each do |inquiry|
        if inquiry.sales_orders.present?
          inquiry.sales_orders.each do |sales_order|
            InquiryMappingTat.where(inquiry_id: inquiry.id, sales_order_id: sales_order.id, sales_quote_id: sales_order.sales_quote.id, inquiry_created_at: inquiry.created_at).first_or_create
          end
          inquiry.sales_quotes.each do |sales_quote|
            InquiryMappingTat.where(inquiry_id: inquiry.id, sales_quote_id: sales_quote.id, inquiry_created_at: inquiry.created_at).first_or_create
          end
        elsif inquiry.sales_quotes.present?
          inquiry.sales_quotes.each do |sales_quote|
            InquiryMappingTat.where(inquiry_id: inquiry.id, sales_quote_id: sales_quote.id, inquiry_created_at: inquiry.created_at).first_or_create
          end
        else
          InquiryMappingTat.where(inquiry_id: inquiry.id, inquiry_created_at: inquiry.created_at).first_or_create
        end
      end
    end
  end

  def add_missing_inquiries_in_inquiry_mapping_tat
    start_date = Date.parse('18-04-2019')
    end_date = Date.parse('03-05-2019')
    inquiries = Inquiry.where(created_at: start_date..end_date).where(status: ['New Inquiry', 'Acknowledgement Mail'])
    inquiries.each do |inquiry|
      if inquiry.status == 'New Inquiry'
        InquiryStatusRecord.where(status: inquiry.status, inquiry: inquiry, subject_type: 'Inquiry', subject_id: inquiry.id).first_or_create
        InquiryMappingTat.where(inquiry_id: inquiry.id, sales_quote_id: nil, sales_order_id: nil, inquiry_created_at: inquiry.created_at).first_or_create
      elsif inquiry.status == 'Acknowledgement Mail'
        InquiryStatusRecord.where(status: 'Acknowledgement Mail', inquiry: inquiry, subject_type: 'Inquiry', subject_id: inquiry.id, created_at: inquiry.updated_at).first_or_create
        InquiryStatusRecord.where(status: 'New Inquiry', inquiry: inquiry, subject_type: 'Inquiry', subject_id: inquiry.id, created_at: inquiry.created_at).first_or_create
        InquiryMappingTat.where(inquiry_id: inquiry.id, sales_quote_id: nil, sales_order_id: nil, inquiry_created_at: inquiry.created_at).first_or_create
      end
    end
  end
end
